import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/punch_list_item.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import 'item_detail_screen.dart';
import '../widgets/punch_list_card.dart';
import '../widgets/summary_card.dart';

class PunchListScreen extends StatefulWidget {
  const PunchListScreen({super.key});

  @override
  State<PunchListScreen> createState() => _PunchListScreenState();
}

class _PunchListScreenState extends State<PunchListScreen> {
  List<PunchListItem> _items = [];
  bool _isLoading = true;
  final AIService _aiService = AIService();
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final items = await dbService.getAllPunchListItems();

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  List<PunchListItem> get _filteredItems {
    if (_filterStatus == 'All') return _items;
    return _items.where((item) => item.status == _filterStatus).toList();
  }

  Future<void> _createPunchListFromPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return;

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing photo...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Get location and project name
      String location = 'Building 3';
      String projectName = 'Construction Project';

      // Generate punch list items from AI
      final items = await _aiService.generatePunchListFromImage(
        File(photo.path),
        location,
        projectName,
      );

      // Save to database
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      for (var item in items) {
        await dbService.insertPunchListItem(item);
      }

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Reload items
      await _loadItems();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created ${items.length} punch list item(s)'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createManualItem() async {
    final result = await showDialog<PunchListItem>(
      context: context,
      builder: (context) => _ManualItemDialog(),
    );

    if (result != null) {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      await dbService.insertPunchListItem(result);
      await _loadItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item created successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Map<String, int> _getSummary() {
    return {
      'total': _items.length,
      'pending': _items.where((i) => i.status == 'Pending').length,
      'inProgress': _items.where((i) => i.status == 'In Progress').length,
      'completed': _items.where((i) => i.status == 'Completed').length,
      'highPriority': _items.where((i) => i.priority == 'High').length,
      'overdue': _items.where((i) => i.isOverdue).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final summary = _getSummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punch List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: CustomScrollView(
                slivers: [
                  // Summary Cards
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  title: 'Total',
                                  value: summary['total'].toString(),
                                  color: Colors.blue,
                                  icon: Icons.list,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SummaryCard(
                                  title: 'Pending',
                                  value: summary['pending'].toString(),
                                  color: Colors.orange,
                                  icon: Icons.pending_actions,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  title: 'In Progress',
                                  value: summary['inProgress'].toString(),
                                  color: Colors.blue.shade400,
                                  icon: Icons.construction,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SummaryCard(
                                  title: 'Completed',
                                  value: summary['completed'].toString(),
                                  color: Colors.green,
                                  icon: Icons.check_circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  title: 'High Priority',
                                  value: summary['highPriority'].toString(),
                                  color: Colors.red,
                                  icon: Icons.priority_high,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SummaryCard(
                                  title: 'Overdue',
                                  value: summary['overdue'].toString(),
                                  color: Colors.red.shade900,
                                  icon: Icons.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All'),
                            _buildFilterChip('Pending'),
                            _buildFilterChip('In Progress'),
                            _buildFilterChip('Completed'),
                            _buildFilterChip('On Hold'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Items List
                  if (_filteredItems.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add a new item',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = _filteredItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PunchListCard(
                                item: item,
                                onTap: () => _openItemDetail(item),
                              ),
                            );
                          },
                          childCount: _filteredItems.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'manual',
            onPressed: _createManualItem,
            backgroundColor: Colors.blue.shade700,
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'camera',
            onPressed: _createPunchListFromPhoto,
            backgroundColor: Colors.green,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = label;
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue.shade700,
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All'),
              onTap: () {
                setState(() => _filterStatus = 'All');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions, color: Colors.orange),
              title: const Text('Pending'),
              onTap: () {
                setState(() => _filterStatus = 'Pending');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.construction, color: Colors.blue),
              title: const Text('In Progress'),
              onTap: () {
                setState(() => _filterStatus = 'In Progress');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Completed'),
              onTap: () {
                setState(() => _filterStatus = 'Completed');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openItemDetail(PunchListItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    );

    if (result == true) {
      await _loadItems();
    }
  }
}

// Manual Item Creation Dialog
class _ManualItemDialog extends StatefulWidget {
  @override
  State<_ManualItemDialog> createState() => _ManualItemDialogState();
}

class _ManualItemDialogState extends State<_ManualItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _assignedToController = TextEditingController();

  String _category = 'Other';
  String _priority = 'Medium';
  double _estimatedHours = 1.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Punch List Item',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Safety',
                    'Finishes',
                    'Structural',
                    'Utilities',
                    'Cleaning',
                    'Other'
                  ]
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: ['High', 'Medium', 'Low']
                      .map((pri) =>
                          DropdownMenuItem(value: pri, child: Text(pri)))
                      .toList(),
                  onChanged: (value) => setState(() => _priority = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _assignedToController,
                  decoration: const InputDecoration(
                    labelText: 'Assigned To',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Estimated Hours: '),
                    Expanded(
                      child: Slider(
                        value: _estimatedHours,
                        min: 0.5,
                        max: 40,
                        divisions: 79,
                        label: _estimatedHours.toStringAsFixed(1),
                        onChanged: (value) =>
                            setState(() => _estimatedHours = value),
                      ),
                    ),
                    Text(_estimatedHours.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final item = PunchListItem(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: _titleController.text,
                            description: _descriptionController.text,
                            location: _locationController.text,
                            category: _category,
                            priority: _priority,
                            assignedTo: _assignedToController.text.isEmpty
                                ? null
                                : _assignedToController.text,
                            estimatedHours: _estimatedHours,
                          );
                          Navigator.pop(context, item);
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
