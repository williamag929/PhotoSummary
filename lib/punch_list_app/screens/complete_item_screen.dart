import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/punch_list_item.dart';
import '../services/database_service.dart';

class CompleteItemScreen extends StatefulWidget {
  final PunchListItem item;
  const CompleteItemScreen({super.key, required this.item});

  @override
  State<CompleteItemScreen> createState() => _CompleteItemScreenState();
}

class _CompleteItemScreenState extends State<CompleteItemScreen> {
  final List<String> _afterPhotos = [];
  final _notesController = TextEditingController();
  String? _tempPhotoPath;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (photo != null) setState(() => _tempPhotoPath = photo.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error taking photo: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _addPhotoToList() {
    if (_tempPhotoPath != null) {
      setState(() {
        _afterPhotos.add(_tempPhotoPath!);
        _tempPhotoPath = null;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() => _afterPhotos.removeAt(index));
  }

  Future<void> _completeItem() async {
    if (_afterPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one "after" photo'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final updatedItem = widget.item.copyWith(
        status: 'Completed',
        completedDate: DateTime.now(),
        photoPaths: [...widget.item.photoPaths, ..._afterPhotos],
        notes: _notesController.text.isEmpty
            ? widget.item.notes
            : _notesController.text,
      );

      final dbService = Provider.of<DatabaseService>(context, listen: false);
      await dbService.updatePunchListItem(updatedItem);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Item marked as completed! ✓'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error completing item: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Mark as Complete'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.green, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quality Check',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green)),
                          const SizedBox(height: 4),
                          Text(
                              'Take photos of completed work from multiple angles to verify quality.',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.green.shade800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.item.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.item.location,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            const Text('Before Photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (widget.item.photoPaths.isEmpty)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No before photos available',
                          style: TextStyle(color: Colors.grey.shade600))))
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.item.photoPaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(widget.item.photoPaths[index]),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image));
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(4)),
                              child: const Text('Before',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            const Text('After Photos *',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 48, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Take Photo',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                      SizedBox(height: 4),
                      Text('Tap to capture',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_tempPhotoPath != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Preview',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  setState(() => _tempPhotoPath = null)),
                        ],
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_tempPhotoPath!),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addPhotoToList,
                          icon: const Icon(Icons.add),
                          label: const Text('Add to List'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_afterPhotos.isNotEmpty) ...[
              Text('Added Photos (${_afterPhotos.length})',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200)),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8),
                  itemCount: _afterPhotos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(_afterPhotos[index]),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover)),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('After',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removePhoto(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            const Text('Completion Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText:
                    'Add notes about the completion...\n(e.g., Quality notes, observations, next steps)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, -2))
        ]),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _afterPhotos.isEmpty ? null : _completeItem,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
