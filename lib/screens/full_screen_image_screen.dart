import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;

  const FullScreenImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
