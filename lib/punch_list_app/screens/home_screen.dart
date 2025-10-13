import 'package:flutter/material.dart';
import 'punch_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.checklist_rounded,
                        size: 60, color: Colors.blue),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Punch List Manager',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI-Powered Construction Management',
                    style: TextStyle(
                        fontSize: 16, color: Colors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  _buildFeatureItem(Icons.photo_camera, 'Take Photos'),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.auto_fix_high, 'AI Analysis'),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.checklist, 'Track Progress'),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.people, 'Team Collaboration'),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PunchListScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                      child: const Text('Get Started',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                        fontSize: 12, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Text(text,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
