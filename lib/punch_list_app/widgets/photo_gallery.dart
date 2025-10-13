import 'package:flutter/material.dart';
import 'dart:io';

class PhotoGallery extends StatelessWidget {
  final List<String> photoPaths;
  final bool showLabels;
  final String? label;

  const PhotoGallery(
      {super.key,
      required this.photoPaths,
      this.showLabels = false,
      this.label});

  @override
  Widget build(BuildContext context) {
    if (photoPaths.isEmpty) {
      return Card(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('No photos available',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoPaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showPhotoDialog(context, photoPaths[index]),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(photoPaths[index]),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  color: Colors.grey.shade600, size: 32),
                              const SizedBox(height: 4),
                              Text('Image not found',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (showLabels && label != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(label!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.zoom_in,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPhotoDialog(BuildContext context, String photoPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                  child: Image.file(File(photoPath), fit: BoxFit.contain)),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
