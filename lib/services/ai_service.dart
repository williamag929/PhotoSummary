import 'dart:io';
//import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:tflite_flutter/tflite_flutter.dart';
//import 'dart:io';

class stateSummary {
  final String? summary;
  stateSummary({this.summary});
}

class AIService {
  // AI image analysis using TensorFlow Lite

  Future<String> analyzeImage(File image) async {
    try {
      //final interpreter = await Interpreter.fromAsset('yolo11n.tflite');
      // Placeholder: Process image for object detection
      // Replace with actual YOLO model inference logic
      // Example output: "Detected: 2 helmets, 1 excavator"
      String result = await _runModelOnImage(image);
      await _summarizeAnalysis(result);

      return result;
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Mock function for running TFLite model (replace with actual model logic)
  Future<String> _runModelOnImage(File image) async {
    // Load image, preprocess, and run inference
    // This is a placeholder; implement YOLO model processing
    return 'Detected: 2 helmets, 1 excavator, 0 safety violations';
  }

  // Summarize analysis results using xAI Grok-3-mini API
  Future<void> _summarizeAnalysis(String analysis) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://api.x.ai/v1/chat/completions',
        ), // Use the Grok-3-mini chat completions endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer key', // Include API key in Authorization header
        },
        body: '{"text": "$analysis"}',
      );
      if (response.statusCode == 200) {
        // Assuming the Grok-3-mini API returns a JSON response with the summary in a 'choices' field
        // You might need to adjust this based on the actual API response structure
        // For example, if the response is: {"choices": [{"message": {"content": "..."}}], ...}
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['choices'] != null &&
            jsonResponse['choices'].isNotEmpty) {
          stateSummary(
            summary: jsonResponse['choices'][0]['message']['content'],
          );
        } else {
          stateSummary(summary: response.body);
        }
      }
    } catch (e) {
      stateSummary(summary: 'Error: $e');
    }
  }
}
