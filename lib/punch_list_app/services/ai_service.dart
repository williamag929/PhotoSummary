import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/punch_list_item.dart';

class AIService {
  // REPLACE WITH YOUR ACTUAL API KEY FROM https://makersuite.google.com/app/apikey
  final String _apiKey =
      dotenv.env['GOOGLE_AI_API_KEY'] ?? 'YOUR_GOOGLE_GEMINI_API_KEY_HERE';
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

  Future<String> _callGenerativeApiWithImage(
      String prompt, File imageFile) async {
    if (_apiKey == 'YOUR_GOOGLE_GEMINI_API_KEY_HERE') {
      print("⚠️ WARNING: API key not configured!");
      return jsonEncode({
        'title': 'Demo Item - Configure API Key',
        'description':
            'Please add your Google Gemini API key in lib/services/ai_service.dart',
        'category': 'Other',
        'priority': 'Medium',
        'estimated_hours': 1.0
      });
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      String mimeType = 'image/jpeg';
      String extension = imageFile.path.split('.').last.toLowerCase();
      if (extension == 'png')
        mimeType = 'image/png';
      else if (extension == 'webp') mimeType = 'image/webp';

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
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
        }
      }
      return '{}';
    } catch (e) {
      print("Error calling AI service with image: $e");
      return '{}';
    }
  }

  Future<List<PunchListItem>> generatePunchListFromImage(
    File image,
    String location,
    String projectName,
  ) async {
    String prompt = '''
You are an expert construction supervisor analyzing a photo for a punch list.
Analyze this image and identify all items that need to be completed, fixed, or addressed.

For each item, create a punch list entry and return as a JSON array:
[
  {
    "title": "Short title of the item (5-10 words)",
    "description": "Detailed description of what needs to be done",
    "category": "One of: Safety, Finishes, Structural, Utilities, Cleaning, Other",
    "priority": "One of: High, Medium, Low",
    "estimated_hours": 2.5
  }
]

Project: $projectName
Location: $location

Be thorough but practical. Return ONLY valid JSON array.
''';

    try {
      String jsonString = await _callGenerativeApiWithImage(prompt, image);
      dynamic jsonResponse = json.decode(jsonString);

      List<dynamic> jsonArray;
      if (jsonResponse is List) {
        jsonArray = jsonResponse;
      } else if (jsonResponse is Map) {
        jsonArray = [jsonResponse];
      } else {
        return [];
      }

      List<PunchListItem> items = [];
      for (int i = 0; i < jsonArray.length; i++) {
        final itemJson = jsonArray[i];
        items.add(PunchListItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          title: itemJson['title'] ?? 'Untitled Item',
          description: itemJson['description'] ?? '',
          location: location,
          category: itemJson['category'] ?? 'Other',
          priority: itemJson['priority'] ?? 'Medium',
          status: 'Pending',
          estimatedHours: (itemJson['estimated_hours'] ?? 1.0).toDouble(),
          photoPaths: [image.path],
        ));
      }

      return items;
    } catch (e) {
      print("Error generating punch list from image: $e");
      return [
        PunchListItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Review Photo',
          description:
              'Failed to analyze image automatically. Please review manually.',
          location: location,
          category: 'Other',
          priority: 'Medium',
          status: 'Pending',
          estimatedHours: 1.0,
          photoPaths: [image.path],
        ),
      ];
    }
  }
}
