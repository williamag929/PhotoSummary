import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

class AIService {
  final String _apiKey = 'your api key here';
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // Generic function to call the generative AI API.
  Future<String> _callGenerativeApi(String prompt) async {
    if (_apiKey == null) {
      print("Warning: API key is not set. Please create a .env file with 'Google_AI_API_KEY=YOUR_API_KEY'");
      return '{"issue": "Placeholder issue: API key not set", "location": "Demo location", "details": "This is a dummy report because the AI service is not configured.", "assigned_to": "Developer"}';
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
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
          String content = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          content = content.replaceAll("```json", "").replaceAll("```", "").trim();
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

  // Analyzes an image to detect objects.
  // TODO: Implement actual image analysis model.
  Future<String> analyzeImage(File image) async {
    // Placeholder for real image analysis.
    return "Image analysis feature not implemented.";
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
      return StructuredReport(issue: "Failed to parse AI response.", details: jsonString);
    }
  }

  Future<AISummary> generateReportSummary(List<Report> reports) async {
    String reportsText = reports.map((r) => "Issue: ${r.issue}, Location: ${r.location}, Details: ${r.details}, Assigned to: ${r.assignedTo}").join("\n");

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
    String reportText = "Issue: ${report.issue}, Location: ${report.location}, Details: ${report.details}";

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
}
