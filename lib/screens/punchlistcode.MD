# COMPLETE PUNCH LIST APP - SINGLE FILE REFERENCE
# Copy this entire content to your AI agent in VS Code

---

## PROJECT STRUCTURE

```
punch_list_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── punch_list_item.dart
│   │   └── report.dart
│   ├── services/
│   │   ├── ai_service.dart
│   │   └── database_service.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── punch_list_screen.dart
│   │   ├── item_detail_screen.dart
│   │   └── complete_item_screen.dart
│   └── widgets/
│       ├── punch_list_card.dart
│       ├── summary_card.dart
│       └── photo_gallery.dart
└── pubspec.yaml
```

---

## FILE 1: pubspec.yaml

```yaml
name: punch_list_app
description: Construction Punch List Management App with AI-powered photo analysis

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  http: ^1.1.0
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  intl: ^0.18.1
  uuid: ^4.2.1
  path: ^1.8.3

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

---

## FILE 2: lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.initDatabase();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punch List Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
```

---

## FILE 3: lib/models/punch_list_item.dart

```dart
class PunchListItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String priority;
  final String status;
  final String? assignedTo;
  final DateTime createdDate;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final List<String> photoPaths;
  final double? estimatedHours;
  final String? notes;

  PunchListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.category = 'Other',
    this.priority = 'Medium',
    this.status = 'Pending',
    this.assignedTo,
    DateTime? createdDate,
    this.dueDate,
    this.completedDate,
    List<String>? photoPaths,
    this.estimatedHours,
    this.notes,
  })  : createdDate = createdDate ?? DateTime.now(),
        photoPaths = photoPaths ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'photoPaths': photoPaths.join(','),
      'estimatedHours': estimatedHours,
      'notes': notes,
    };
  }

  factory PunchListItem.fromMap(Map<String, dynamic> map) {
    return PunchListItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] ?? 'Other',
      priority: map['priority'] ?? 'Medium',
      status: map['status'] ?? 'Pending',
      assignedTo: map['assignedTo'],
      createdDate: DateTime.parse(map['createdDate']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      completedDate: map['completedDate'] != null ? DateTime.parse(map['completedDate']) : null,
      photoPaths: map['photoPaths'] != null && map['photoPaths'].isNotEmpty
          ? map['photoPaths'].split(',')
          : [],
      estimatedHours: map['estimatedHours']?.toDouble(),
      notes: map['notes'],
    );
  }

  PunchListItem copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? createdDate,
    DateTime? dueDate,
    DateTime? completedDate,
    List<String>? photoPaths,
    double? estimatedHours,
    String? notes,
  }) {
    return PunchListItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      photoPaths: photoPaths ?? this.photoPaths,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue {
    if (status == 'Completed' || dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }
}
```

---

## FILE 4: lib/models/report.dart

```dart
class Report {
  final String id;
  final String issue;
  final String location;
  final String details;
  final String assignedTo;
  final DateTime createdDate;

  Report({
    required this.id,
    required this.issue,
    required this.location,
    required this.details,
    required this.assignedTo,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'issue': issue,
      'location': location,
      'details': details,
      'assignedTo': assignedTo,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] ?? '',
      issue: map['issue'] ?? '',
      location: map['location'] ?? '',
      details: map['details'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      createdDate: DateTime.parse(map['createdDate']),
    );
  }
}
```

---

## FILE 5: lib/services/database_service.dart

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/punch_list_item.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'punch_list.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE punch_list_items(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            location TEXT,
            category TEXT,
            priority TEXT,
            status TEXT,
            assignedTo TEXT,
            createdDate TEXT,
            dueDate TEXT,
            completedDate TEXT,
            photoPaths TEXT,
            estimatedHours REAL,
            notes TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertPunchListItem(PunchListItem item) async {
    final db = await database;
    return await db.insert(
      'punch_list_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PunchListItem>> getAllPunchListItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'punch_list_items',
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (i) => PunchListItem.fromMap(maps[i]));
  }

  Future<List<PunchListItem>> getItemsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'punch_list_items',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdDate DESC',
    );
    return List.generate(maps.length, (i) => PunchListItem.fromMap(maps[i]));
  }

  Future<int> updatePunchListItem(PunchListItem item) async {
    final db = await database;
    return await db.update(
      'punch_list_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deletePunchListItem(String id) async {
    final db = await database;
    return await db.delete(
      'punch_list_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<PunchListItem?> getPunchListItem(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'punch_list_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return PunchListItem.fromMap(maps.first);
  }

  Future<Map<String, int>> getSummary() async {
    final db = await database;
    
    final total = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM punch_list_items')
    ) ?? 0;
    
    final pending = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM punch_list_items WHERE status = ?', ['Pending'])
    ) ?? 0;
    
    final inProgress = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM punch_list_items WHERE status = ?', ['In Progress'])
    ) ?? 0;
    
    final completed = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM punch_list_items WHERE status = ?', ['Completed'])
    ) ?? 0;
    
    final highPriority = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM punch_list_items WHERE priority = ?', ['High'])
    ) ?? 0;

    return {
      'total': total,
      'pending': pending,
      'inProgress': inProgress,
      'completed': completed,
      'highPriority': highPriority,
    };
  }
}
```

---

## FILE 6: lib/services/ai_service.dart

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/punch_list_item.dart';

class AIService {
  // REPLACE WITH YOUR ACTUAL API KEY FROM https://makersuite.google.com/app/apikey
  final String _apiKey = 'YOUR_GOOGLE_GEMINI_API_KEY_HERE';
  final String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

  Future<String> _callGenerativeApiWithImage(String prompt, File imageFile) async {
    if (_apiKey == 'YOUR_GOOGLE_GEMINI_API_KEY_HERE') {
      print("⚠️ WARNING: API key not configured!");
      return jsonEncode({
        'title': 'Demo Item - Configure API Key',
        'description': 'Please add your Google Gemini API key in lib/services/ai_service.dart',
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
      if (extension == 'png') mimeType = 'image/png';
      else if (extension == 'webp') mimeType = 'image/webp';

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [
              {"text": prompt},
              {"inline_data": {"mime_type": mimeType, "data": base64Image}}
            ]
          }],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['candidates'] != null && jsonResponse['candidates'].isNotEmpty) {
          String content = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
          content = content.replaceAll("```json", "").replaceAll("```", "").trim();
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
          description: 'Failed to analyze image automatically. Please review manually.',
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
```

---

## FILE 7: lib/screens/home_screen.dart

```dart
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
                    child: const Icon(Icons.checklist_rounded, size: 60, color: Colors.blue),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Punch List Manager',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI-Powered Construction Management',
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
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
                          MaterialPageRoute(builder: (context) => const PunchListScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                      child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
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
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
```

---

## FILE 8-11: See next message for remaining screens and widgets

**INSTRUCTIONS FOR AI AGENT:**

1. Create a new Flutter project: `flutter create punch_list_app`
2. Copy pubspec.yaml content above
3. Run: `flutter pub get`
4. Create all folders: models, services, screens, widgets
5. Copy each file content to its respective location
6. Replace API key in ai_service.dart with actual Gemini key
7. Update AndroidManifest.xml with camera permissions
8. Update iOS Info.plist with camera permissions
9. Run: `flutter run`

**REFACTORING SUGGESTIONS:**
- Separate UI components into smaller widgets
- Add error handling wrapper service
- Implement repository pattern for database
- Add unit tests for models and services
- Create constants file for colors and strings
- Add logging service for debugging
- Implement state management with Riverpod or Bloc
- Add offline sync mechanism
- Create custom theme file
- Add analytics tracking

Continue to next message for remaining files...
```

---

// ============================================================================
// PUNCH LIST APP - COMPLETE CODE FOR AI AGENT
// Copy this ENTIRE file to your AI agent in VS Code
// ============================================================================

// FILE: lib/screens/punch_list_screen.dart (CONTINUED)
// Add after line 12 in previous snippet:

                              const SizedBox(width: 12),
                              Expanded(child: SummaryCard(title: 'Completed', value: summary['completed'].toString(), color: Colors.green, icon: Icons.check_circle)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: SummaryCard(title: 'High Priority', value: summary['highPriority'].toString(), color: Colors.red, icon: Icons.priority_high)),
                              const SizedBox(width: 12),
                              Expanded(child: SummaryCard(title: 'Overdue', value: summary['overdue'].toString(), color: Colors.red.shade900, icon: Icons.warning)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All'),
                            _buildFilterChip('Pending'),
                            _buildFilterChip('In Progress'),
                            _buildFilterChip('Completed'),
                            _buildFilterChip('On Hold'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (_filteredItems.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.checklist_rounded, size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text('No items found', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                            const SizedBox(height: 8),
                            Text('Tap + to add a new item', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = _filteredItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PunchListCard(item: item, onTap: () => _openItemDetail(item)),
                            );
                          },
                          childCount: _filteredItems.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'manual',
            onPressed: _createManualItem,
            backgroundColor: Colors.blue.shade700,
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'camera',
            onPressed: _createPunchListFromPhoto,
            backgroundColor: Colors.green,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _filterStatus = label),
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue.shade700,
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All'),
              onTap: () {
                setState(() => _filterStatus = 'All');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions, color: Colors.orange),
              title: const Text('Pending'),
              onTap: () {
                setState(() => _filterStatus = 'Pending');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.construction, color: Colors.blue),
              title: const Text('In Progress'),
              onTap: () {
                setState(() => _filterStatus = 'In Progress');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Completed'),
              onTap: () {
                setState(() => _filterStatus = 'Completed');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openItemDetail(PunchListItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
    );
    if (result == true) await _loadItems();
  }
}

// Manual Item Dialog
class _ManualItemDialog extends StatefulWidget {
  @override
  State<_ManualItemDialog> createState() => _ManualItemDialogState();
}

class _ManualItemDialogState extends State<_ManualItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _assignedToController = TextEditingController();
  
  String _category = 'Other';
  String _priority = 'Medium';
  double _estimatedHours = 1.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Punch List Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: ['Safety', 'Finishes', 'Structural', 'Utilities', 'Cleaning', 'Other']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: ['High', 'Medium', 'Low']
                      .map((pri) => DropdownMenuItem(value: pri, child: Text(pri)))
                      .toList(),
                  onChanged: (value) => setState(() => _priority = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _assignedToController,
                  decoration: const InputDecoration(labelText: 'Assigned To', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Estimated Hours: '),
                    Expanded(
                      child: Slider(
                        value: _estimatedHours,
                        min: 0.5,
                        max: 40,
                        divisions: 79,
                        label: _estimatedHours.toStringAsFixed(1),
                        onChanged: (value) => setState(() => _estimatedHours = value),
                      ),
                    ),
                    Text(_estimatedHours.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final item = PunchListItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: _titleController.text,
                            description: _descriptionController.text,
                            location: _locationController.text,
                            category: _category,
                            priority: _priority,
                            assignedTo: _assignedToController.text.isEmpty ? null : _assignedToController.text,
                            estimatedHours: _estimatedHours,
                          );
                          Navigator.pop(context, item);
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FILE: lib/screens/item_detail_screen.dart
// ============================================================================

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
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'In Progress': return Colors.blue;
      case 'On Hold': return Colors.grey;
      default: return Colors.orange;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Safety': return '⚠️';
      case 'Finishes': return '🎨';
      case 'Structural': return '🏗️';
      case 'Utilities': return '⚡';
      case 'Cleaning': return '🧹';
      default: return '📋';
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
        actions: [IconButton(icon: const Icon(Icons.delete), onPressed: _deleteItem)],
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
                      Text(_getCategoryEmoji(_item.category), style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _item.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_item.location, style: const TextStyle(fontSize: 16, color: Colors.white70)),
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
                      Expanded(child: _buildDetailCard('Status', _item.status, icon: Icons.info, color: _getStatusColor(_item.status))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDetailCard('Priority', _item.priority, icon: Icons.flag, color: _getPriorityColor(_item.priority))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDetailCard('Category', _item.category, icon: Icons.category)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDetailCard('Est. Hours', '${_item.estimatedHours?.toStringAsFixed(1) ?? "N/A"}h', icon: Icons.access_time)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_item.assignedTo != null)
                    _buildDetailCard('Assigned To', _item.assignedTo!, icon: Icons.person),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDetailCard('Created', dateFormat.format(_item.createdDate), icon: Icons.calendar_today)),
                      const SizedBox(width: 12),
                      if (_item.dueDate != null)
                        Expanded(child: _buildDetailCard('Due Date', dateFormat.format(_item.dueDate!), icon: Icons.event, color: _item.isOverdue ? Colors.red : null)),
                    ],
                  ),
                  if (_item.completedDate != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard('Completed', dateFormat.format(_item.completedDate!), icon: Icons.check_circle, color: Colors.green),
                  ],
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _item.description.isEmpty ? 'No description provided' : _item.description,
                        style: TextStyle(fontSize: 16, color: _item.description.isEmpty ? Colors.grey : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_item.photoPaths.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${_item.photoPaths.length} photo(s)', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
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
                    const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_item.notes!, style: const TextStyle(fontSize: 16)),
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

  Widget _buildDetailCard(String label, String value, {IconData? icon, Color? color}) {
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
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
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
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, -2))],
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
                    Text('Item Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
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
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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

// Continue to next message for remaining files...

// ============================================================================
// PUNCH LIST APP - FINAL FILES
// Complete Item Screen + All Widgets
// ============================================================================

// FILE: lib/screens/complete_item_screen.dart

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
      final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (photo != null) setState(() => _tempPhotoPath = photo.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e'), backgroundColor: Colors.red),
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
        const SnackBar(content: Text('Please add at least one "after" photo'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final updatedItem = widget.item.copyWith(
        status: 'Completed',
        completedDate: DateTime.now(),
        photoPaths: [...widget.item.photoPaths, ..._afterPhotos],
        notes: _notesController.text.isEmpty ? widget.item.notes : _notesController.text,
      );

      final dbService = Provider.of<DatabaseService>(context, listen: false);
      await dbService.updatePunchListItem(updatedItem);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item marked as completed! ✓'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing item: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark as Complete'), backgroundColor: Colors.green),
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
                    const Icon(Icons.info_outline, color: Colors.green, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quality Check', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                          const SizedBox(height: 4),
                          Text('Take photos of completed work from multiple angles to verify quality.', style: TextStyle(fontSize: 14, color: Colors.green.shade800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.item.location, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            const Text('Before Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (widget.item.photoPaths.isEmpty)
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('No before photos available', style: TextStyle(color: Colors.grey.shade600))))
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
                                return Container(width: 100, height: 100, color: Colors.grey.shade300, child: const Icon(Icons.broken_image));
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Before', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            const Text('After Photos *', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      Text('Take Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                      SizedBox(height: 4),
                      Text('Tap to capture', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                          const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _tempPhotoPath = null)),
                        ],
                      ),
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_tempPhotoPath!), width: double.infinity, height: 200, fit: BoxFit.cover)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addPhotoToList,
                          icon: const Icon(Icons.add),
                          label: const Text('Add to List'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_afterPhotos.isNotEmpty) ...[
              Text('Added Photos (${_afterPhotos.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: _afterPhotos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_afterPhotos[index]), width: double.infinity, height: double.infinity, fit: BoxFit.cover)),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                            child: const Text('After', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removePhoto(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
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
            const Text('Completion Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add notes about the completion...\n(e.g., Quality notes, observations, next steps)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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

// ============================================================================
// FILE: lib/widgets/punch_list_card.dart
// ============================================================================

import 'package:flutter/material.dart';
import '../models/punch_list_item.dart';
import 'package:intl/intl.dart';

class PunchListCard extends StatelessWidget {
  final PunchListItem item;
  final VoidCallback onTap;

  const PunchListCard({super.key, required this.item, required this.onTap});

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'In Progress': return Colors.blue;
      case 'On Hold': return Colors.grey;
      default: return Colors.orange;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Safety': return '⚠️';
      case 'Finishes': return '🎨';
      case 'Structural': return '🏗️';
      case 'Utilities': return '⚡';
      case 'Cleaning': return '🧹';
      default: return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(item.priority);
    final statusColor = _getStatusColor(item.status);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: priorityColor.withOpacity(0.3), width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: priorityColor, width: 6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_getCategoryEmoji(item.category), style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (item.description.isNotEmpty)
                  Text(item.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade700), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.location_on, item.location, Colors.blue),
                    _buildInfoChip(Icons.access_time, '${item.estimatedHours?.toStringAsFixed(1) ?? "?"} hrs', Colors.purple),
                    if (item.assignedTo != null) _buildInfoChip(Icons.person, item.assignedTo!, Colors.teal),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: priorityColor)),
                          child: Text(item.priority, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: priorityColor)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                          child: Text(item.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    if (item.photoPaths.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.photo_camera, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${item.photoPaths.length}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
                if (item.isOverdue)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.red)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('Overdue: ${DateFormat('MMM dd').format(item.dueDate!)}', style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color.shade700)),
        ],
      ),
    );
  }
}

// ============================================================================
// FILE: lib/widgets/summary_card.dart
// ============================================================================

import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const SummaryCard({super.key, required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FILE: lib/widgets/photo_gallery.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'dart:io';

class PhotoGallery extends StatelessWidget {
  final List<String> photoPaths;
  final bool showLabels;
  final String? label;

  const PhotoGallery({super.key, required this.photoPaths, this.showLabels = false, this.label});

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
                Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('No photos available', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
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
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey.shade600, size: 32),
                              const SizedBox(height: 4),
                              Text('Image not found', style: TextStyle(fontSize: 10, color: Colors.grey.shade600), textAlign: TextAlign.center),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                        child: Text(label!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
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
              child: Center(child: Image.file(File(photoPath), fit: BoxFit.contain)),
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

// ============================================================================
// END OF ALL FILES
// ============================================================================

/*
SETUP INSTRUCTIONS FOR AI AGENT:

1. Create project: flutter create punch_list_app
2. Copy pubspec.yaml from Part 1
3. Run: flutter pub get
4. Create folders: mkdir -p lib/{models,services,screens,widgets}
5. Copy all files to their respective locations
6. Add Gemini API key in lib/services/ai_service.dart
7. Update AndroidManifest.xml with camera permissions
8. Update iOS Info.plist with camera permissions
9. Run: flutter run

REFACTORING RECOMMENDATIONS:
- Split large files into smaller modules
- Add dependency injection
- Implement repository pattern
- Add error boundary wrapper
- Create constants file
- Add unit tests
- Implement state management (Riverpod/Bloc)
- Add analytics tracking
- Implement offline sync
- Add logging service
*/

