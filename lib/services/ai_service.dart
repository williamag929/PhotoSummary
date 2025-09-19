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

class TranscribedMemo {
  final String text;
  final String location;
  final String subcontractor;
  final String priority;

  TranscribedMemo({
    required this.text,
    required this.location,
    required this.subcontractor,
    required this.priority,
  });
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

  Future<String> getSpec(String query) async {
    // In a real app, this would query a database or an API.
    // For this demo, we'll return a canned response.
    if (query.contains("conduit supports")) {
      return "Specification E-301, section 4.2 states: 'Conduit supports for 3/4 inch EMT must be spaced at a maximum of 10 feet on center.'";
    }
    return "I'm sorry, I couldn't find that specification.";
  }

  Future<TranscribedMemo> transcribeVoiceMemo(String audioPath) async {
    // In a real app, this would use a speech-to-text API.
    // For this demo, we'll return a canned response based on the user story.
    return TranscribedMemo(
      text:
          "Non-conformance issue. Conduit supports are spaced at twelve feet. Specification E-301 requires ten-foot spacing.",
      location: "Fourth floor, northeast quadrant, above grid line C",
      subcontractor: "Sparks Electrical",
      priority: "Needs to be remediated before the ceiling grid is installed on Friday.",
    );
  }
}
