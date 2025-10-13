import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/punch_list_item.dart';
import '../services/database_service.dart';
import 'complete_item_screen.dart';
import 'package:intl/intl.dart';

class ItemDetailScreen extends StatefulWidget {
  final PunchListItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late PunchListItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'On Hold':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Safety':
        return '⚠️';
      case 'Finishes':
        return '🎨';
      case 'Structural':
        return '🏗️';
      case 'Utilities':
        return '⚡';
      case 'Cleaning':
        return '🧹';
      default:
        return '📋';
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final updatedItem = _item.copyWith(
      status: newStatus,
      completedDate: newStatus == 'Completed' ? DateTime.now() : null,
    );

    final dbService = Provider.of<DatabaseService>(context, listen: false);
    await dbService.updatePunchListItem(updatedItem);

    setState(() => _item = updatedItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $newStatus'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      await dbService.deletePunchListItem(_item.id);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _markComplete() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CompleteItemScreen(item: _item)),
    );

    if (result == true) {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final updatedItem = await dbService.getPunchListItem(_item.id);
      if (updatedItem != null) setState(() => _item = updatedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteItem)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getPriorityColor(_item.priority).withOpacity(0.8),
                    _getPriorityColor(_item.priority),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_getCategoryEmoji(_item.category),
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _item.title,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_item.location,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _buildDetailCard('Status', _item.status,
                              icon: Icons.info,
                              color: _getStatusColor(_item.status))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildDetailCard('Priority', _item.priority,
                              icon: Icons.flag,
                              color: _getPriorityColor(_item.priority))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildDetailCard('Category', _item.category,
                              icon: Icons.category)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildDetailCard('Est. Hours',
                              '${_item.estimatedHours?.toStringAsFixed(1) ?? "N/A"}h',
                              icon: Icons.access_time)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_item.assignedTo != null)
                    _buildDetailCard('Assigned To', _item.assignedTo!,
                        icon: Icons.person),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildDetailCard(
                              'Created', dateFormat.format(_item.createdDate),
                              icon: Icons.calendar_today)),
                      const SizedBox(width: 12),
                      if (_item.dueDate != null)
                        Expanded(
                            child: _buildDetailCard(
                                'Due Date', dateFormat.format(_item.dueDate!),
                                icon: Icons.event,
                                color: _item.isOverdue ? Colors.red : null)),
                    ],
                  ),
                  if (_item.completedDate != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                        'Completed', dateFormat.format(_item.completedDate!),
                        icon: Icons.check_circle, color: Colors.green),
                  ],
                  const SizedBox(height: 24),
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _item.description.isEmpty
                            ? 'No description provided'
                            : _item.description,
                        style: TextStyle(
                            fontSize: 16,
                            color: _item.description.isEmpty
                                ? Colors.grey
                                : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_item.photoPaths.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Photos',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${_item.photoPaths.length} photo(s)',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _item.photoPaths.length,
                        itemBuilder: (context, index) {
                          final photoPath = _item.photoPaths[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => _showPhotoDialog(photoPath),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(photoPath),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_item.notes != null && _item.notes!.isNotEmpty) ...[
                    const Text('Notes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_item.notes!,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildDetailCard(String label, String value,
      {IconData? icon, Color? color}) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
                  const SizedBox(width: 4),
                ],
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_item.status != 'Completed') ...[
              Row(
                children: [
                  if (_item.status == 'Pending')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus('In Progress'),
                        icon: const Icon(Icons.construction),
                        label: const Text('Start Work'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (_item.status == 'In Progress') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus('On Hold'),
                        icon: const Icon(Icons.pause),
                        label: const Text('On Hold'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _markComplete,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                  if (_item.status == 'On Hold')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus('In Progress'),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            if (_item.status == 'Completed')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Item Completed',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPhotoDialog(String photoPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Photo'),
              leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.file(File(photoPath), fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
