import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/report.dart';

// A simple data class for the structured report data.
class StructuredReport {
  final String issue;
  final String location;
  final String details;
  final String assignedTo;

  StructuredReport({
    this.issue = "",
    this.location = "",
    this.details = "",
    this.assignedTo = "",
  });

  factory StructuredReport.fromJson(Map<String, dynamic> json) {
    return StructuredReport(
      issue: json['issue'] ?? '',
      location: json['location'] ?? '',
      details: json['details'] ?? '',
      assignedTo: json['assigned_to'] ?? '',
    );
  }
}

class AISummary {
  final int totalIssues;
  final int safetyIssues;
  final String summaryText;

  AISummary({
    this.totalIssues = 0,
    this.safetyIssues = 0,
    this.summaryText = "",
  });

  factory AISummary.fromJson(Map<String, dynamic> json) {
    return AISummary(
      totalIssues: json['total_issues'] ?? 0,
      safetyIssues: json['safety_issues'] ?? 0,
      summaryText: json['summary_text'] ?? '',
    );
  }
}

// NEW: Data class for image analysis results
class ImageAnalysisResult {
  final String summary;
  final List<String> hazards;
  final List<String> oshaRecommendations;
  final List<String> missingPPE;
  final String detailedDescription;

  ImageAnalysisResult({
    this.summary = "",
    this.hazards = const [],
    this.oshaRecommendations = const [],
    this.missingPPE = const [],
    this.detailedDescription = "",
  });

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ImageAnalysisResult(
      summary: json['summary'] ?? '',
      hazards:
          json['hazards'] != null ? List<String>.from(json['hazards']) : [],
      oshaRecommendations: json['osha_recommendations'] != null
          ? List<String>.from(json['osha_recommendations'])
          : [],
      missingPPE: json['missing_ppe'] != null
          ? List<String>.from(json['missing_ppe'])
          : [],
      detailedDescription: json['detailed_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'hazards': hazards,
      'osha_recommendations': oshaRecommendations,
      'missing_ppe': missingPPE,
      'detailed_description': detailedDescription,
    };
  }
}

class AIService {
  final String _apiKey = dotenv.env['GOOGLE_AI_API_KEY']!;
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // Generic function to call the generative AI API (text only).
  Future<String> _callGenerativeApi(String prompt) async {
    if (_apiKey == null || _apiKey == 'your api key here') {
      print(
          "Warning: API key is not set. Please create a .env file with 'Google_AI_API_KEY=YOUR_API_KEY'");
      return '{"issue": "Placeholder issue: API key not set", "location": "Demo location", "details": "This is a dummy report because the AI service is not configured.", "assigned_to": "Developer"}';
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty) {
          String content =
              jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          content =
              content.replaceAll("```json", "").replaceAll("```", "").trim();
          return content;
        } else {
          return '{"error": "Invalid response structure from API."}';
        }
      } else {
        print("API Error: ${response.statusCode}");
        print("API Response: ${response.body}");
        return '{"error": "Failed to communicate with AI service. Status code: ${response.statusCode}"}';
      }
    } catch (e) {
      print("Error calling AI service: $e");
      return '{"error": "An exception occurred while contacting the AI service: $e"}';
    }
  }

  // NEW: Generic function to call the API with image support
  Future<String> _callGenerativeApiWithImage(
      String prompt, File imageFile) async {
    if (_apiKey == null || _apiKey == 'your api key here') {
      print("Warning: API key is not set.");
      return '{"summary": "API key not configured", "hazards": [], "osha_recommendations": ["Configure API key to enable image analysis"], "missing_ppe": [], "detailed_description": "API key is not set"}';
    }

    try {
      // Read image file and convert to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Determine MIME type based on file extension
      String mimeType = 'image/jpeg';
      String extension = imageFile.path.split('.').last.toLowerCase();
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      } else if (extension == 'heic') {
        mimeType = 'image/heic';
      } else if (extension == 'heif') {
        mimeType = 'image/heif';
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inline_data": {"mime_type": mimeType, "data": base64Image}
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.4,
            "topK": 32,
            "topP": 1,
            "maxOutputTokens": 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty) {
          String content =
              jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          // Clean up markdown code blocks
          content =
              content.replaceAll("```json", "").replaceAll("```", "").trim();
          return content;
        } else {
          return '{"error": "Invalid response structure from API."}';
        }
      } else {
        print("API Error: ${response.statusCode}");
        print("API Response: ${response.body}");
        return '{"error": "Failed to communicate with AI service. Status code: ${response.statusCode}"}';
      }
    } catch (e) {
      print("Error calling AI service with image: $e");
      return '{"error": "An exception occurred while contacting the AI service: $e"}';
    }
  }

  // NEW: Analyzes an image for construction site safety hazards and OSHA compliance
  Future<ImageAnalysisResult> analyzeImage(File image) async {
    String prompt = '''
You are an expert in construction site safety and OSHA compliance.
Analyze this image from a construction site and provide a comprehensive safety assessment.

Return your analysis as a JSON object with the following structure:
{
  "summary": "Brief 1-2 sentence summary of what you see in the image (max 50 words)",
  "hazards": ["List of specific safety hazards you identify in the image"],
  "osha_recommendations": ["List of 3-5 specific OSHA safety recommendations based on what you see"],
  "missing_ppe": ["List of Personal Protective Equipment that should be present but isn't visible"],
  "detailed_description": "Detailed description of the scene, work being performed, and safety context (100-150 words)"
}

Focus on:
- Visible safety hazards (fall hazards, electrical, struck-by, caught-in/between)
- Missing or improper PPE (hard hats, safety glasses, gloves, high-visibility vests, safety harnesses)
- Housekeeping issues (trip hazards, materials storage)
- Equipment safety (guards, proper use)
- OSHA compliance violations
- Environmental conditions

Be specific and practical in your recommendations.
Only return valid JSON, no additional text.
''';

    try {
      String jsonString = await _callGenerativeApiWithImage(prompt, image);

      // Parse the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(jsonString);
      return ImageAnalysisResult.fromJson(jsonResponse);
    } catch (e) {
      print("Error analyzing image: $e");
      // Return a fallback result
      return ImageAnalysisResult(
        summary: "Unable to analyze image at this time",
        hazards: ["Error occurred during analysis"],
        oshaRecommendations: [
          "Ensure all workers wear appropriate PPE",
          "Maintain good housekeeping practices",
          "Follow OSHA safety guidelines for your work area"
        ],
        missingPPE: [],
        detailedDescription: "Image analysis failed: $e",
      );
    }
  }

  // NEW: Quick safety check - returns just the summary and top 3 recommendations
  Future<Map<String, dynamic>> quickSafetyCheck(File image) async {
    String prompt = '''
You are a construction safety expert. Quickly analyze this image and provide:
1. A one-sentence summary
2. Top 3 immediate safety concerns or recommendations

Return as JSON:
{
  "summary": "One sentence description",
  "top_concerns": ["concern1", "concern2", "concern3"]
}

Only return valid JSON.
''';

    try {
      String jsonString = await _callGenerativeApiWithImage(prompt, image);
      return json.decode(jsonString);
    } catch (e) {
      print("Error in quick safety check: $e");
      return {
        "summary": "Unable to perform quick analysis",
        "top_concerns": ["Analysis failed - please try again"]
      };
    }
  }

  // Queries for specific project specifications.
  Future<String> getSpec(String query) async {
    String prompt =
        "You are an expert on construction project specifications. Answer the following question based on standard specifications. If you don't know, say you couldn't find the specification.\n\nQuestion: $query";

    String response = await _callGenerativeApi(prompt);
    return response;
  }

  // Processes transcribed voice memo text to extract structured data.
  Future<StructuredReport> processTranscribedText(String rawText) async {
    String prompt = '''
      You are an AI assistant for a construction site reporting app.
      Your task is to extract structured information from a user's voice memo.
      The user will provide a text transcription. Analyze it and return a JSON object with the following fields:
      - "issue": A clear and concise description of the main problem or observation.
      - "location": The specific location mentioned in the memo.
      - "details": Any additional details, context, or required actions.
      - "assigned_to": The person or trade a task is assigned to, if mentioned.

      If a field is not mentioned, leave it as an empty string.
      Do not add any extra commentary. Only return the JSON object.

      Here is the transcription:
      "$rawText"
    ''';

    String jsonString = await _callGenerativeApi(prompt);

    try {
      final Map<String, dynamic> jsonResponse = json.decode(jsonString);
      return StructuredReport.fromJson(jsonResponse);
    } catch (e) {
      print("Error decoding JSON from AI: $e");
      print("Received string: $jsonString");
      return StructuredReport(
          issue: "Failed to parse AI response.", details: jsonString);
    }
  }

  Future<AISummary> generateReportSummary(List<Report> reports) async {
    String reportsText = reports
        .map((r) =>
            "Issue: ${r.issue}, Location: ${r.location}, Details: ${r.details}, Assigned to: ${r.assignedTo}")
        .join("\n");

    String prompt = """
      You are an AI assistant for a construction site reporting app.
      Your task is to create a concise summary of the daily reports.
      The user will provide a list of reports. Analyze them and return a JSON object with the following fields:
      - "total_issues": The total number of issues reported.
      - "safety_issues": The number of issues specifically related to safety.
      - "summary_text": A short summary of the most important issues, progress, and observations.

      If a field is not applicable, return 0 for the counts and an empty string for the summary.
      Do not add any extra commentary. Only return the JSON object.

      Here are the reports:
      "${reportsText}"
    """;

    String jsonString = await _callGenerativeApi(prompt);

    try {
      final Map<String, dynamic> jsonResponse = json.decode(jsonString);
      return AISummary.fromJson(jsonResponse);
    } catch (e) {
      print("Error decoding JSON from AI summary: $e");
      print("Received string for summary: $jsonString");
      return AISummary(summaryText: "Failed to parse AI summary.");
    }
  }

  Future<List<String>> checkForSafetyViolations(Report report) async {
    String reportText =
        "Issue: ${report.issue}, Location: ${report.location}, Details: ${report.details}";

    String prompt = """
      You are an AI assistant specializing in construction site safety.
      Your task is to analyze a report and identify potential safety violations.
      Based on the report, provide a list of recommendations to mitigate the risks.
      If no safety violations are found, return an empty list.
      Return the recommendations as a JSON array of strings.

      Here is the report:
      "${reportText}"
    """;

    String jsonString = await _callGenerativeApi(prompt);

    try {
      final List<dynamic> jsonResponse = json.decode(jsonString);
      return jsonResponse.map((e) => e.toString()).toList();
    } catch (e) {
      print("Error decoding JSON from AI safety check: $e");
      print("Received string for safety check: $jsonString");
      return ["No recommendations found for this note."];
    }
  }

  // NEW: Analyze image and create a structured report automatically
  Future<StructuredReport> createReportFromImage(
      File image, String location) async {
    String prompt = '''
You are an AI assistant for a construction site reporting app.
Analyze this image and create a structured safety report.

Return a JSON object with:
{
  "issue": "Clear description of the main issue or observation",
  "location": "$location",
  "details": "Detailed description including safety concerns and recommendations",
  "assigned_to": "Suggested person/trade to address this (e.g., 'Safety Manager', 'Electrician', 'General Contractor')"
}

Focus on safety hazards, compliance issues, and actionable items.
Only return valid JSON.
''';

    try {
      String jsonString = await _callGenerativeApiWithImage(prompt, image);
      final Map<String, dynamic> jsonResponse = json.decode(jsonString);
      return StructuredReport.fromJson(jsonResponse);
    } catch (e) {
      print("Error creating report from image: $e");
      return StructuredReport(
        issue: "Image analysis report",
        location: location,
        details: "Failed to analyze image: $e",
        assignedTo: "Review needed",
      );
    }
  }
}
