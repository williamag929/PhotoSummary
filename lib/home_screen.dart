import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import './models/report.dart';
import './services/database_service.dart';
import './services/pdf_service.dart';
import './services/ai_service.dart';
import './services/settings_service.dart';
import './report_screen.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import './providers/project_provider.dart';
import './screens/project_screen.dart';
import './screens/settings_screen.dart';
import './screens/full_screen_image_screen.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;

  const HomeScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final PdfService _pdfService = PdfService();
  final AIService _aiService = AIService();
  final SettingsService _settingsService = SettingsService();
  List<Report> _reports = [];
  int? _currentProjectId;

  @override
  void initState() {
    super.initState();
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    projectProvider.fetchProjects().then((_) {
      if (projectProvider.currentProject != null) {
        _loadReports(projectProvider.currentProject!.id);
      } else {
        _loadReports(null);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final projectProvider = Provider.of<ProjectProvider>(context);
    if (_currentProjectId != projectProvider.currentProject?.id) {
      _currentProjectId = projectProvider.currentProject?.id;
      _loadReports(_currentProjectId);
    }
  }

  Future<void> _loadReports(int? projectId) async {
    final reports = await _dbService.getReports(projectId: projectId);
    setState(() {
      _reports = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final currentProject = projectProvider.currentProject;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentProject?.name ?? 'JobLog'),
        actions: [
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generateReport(currentProject?.name ?? "Unknown Project"),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          String? firstImage;
          if (report.photoPath != null) {
            if (report.photoPath!.startsWith('[')) {
              try {
                final List<dynamic> imagePaths = jsonDecode(report.photoPath!);
                if (imagePaths.isNotEmpty) {
                  firstImage = imagePaths.first as String;
                }
              } catch (e) {
                firstImage = report.photoPath; // Fallback for single image path
              }
            } else {
              firstImage = report.photoPath;
            }
          }

          return Dismissible(
            key: Key(report.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteReport(report);
            },
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text(
                        "Are you sure you wish to delete this report?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("DELETE")),
                    ],
                  );
                },
              );
            },
            child: ListTile(
              leading: firstImage != null
                  ? Image.file(File(firstImage))
                  : null,
              title: Text(report.issue),
              subtitle: Text(report.location),
              onTap: () => _showReportDetails(report),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        child: Icon(Icons.add_a_photo),
        onPressed: _navigateToReportScreen,
      ),
    );
  }

  void _showReportDetails(Report report) {
    final issueController = TextEditingController(text: report.issue);
    final locationController = TextEditingController(text: report.location);
    final detailsController = TextEditingController(text: report.details);
    final assignedToController = TextEditingController(text: report.assignedTo);

    List<Widget> imageWidgets = [];
    if (report.photoPath != null) {
      if (report.photoPath!.startsWith('[')) {
        try {
          final List<dynamic> imagePaths = jsonDecode(report.photoPath!);
          imageWidgets = imagePaths.map((path) {
            final imagePath = path as String;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenImageScreen(imagePath: imagePath),
                    ),
                  );
                },
                child: Hero(
                  tag: imagePath,
                  child: Image.file(
                    File(imagePath),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList();
        } catch (e) {
          imageWidgets.add(_buildFullImage(report.photoPath!));
        }
      } else {
        imageWidgets.add(_buildFullImage(report.photoPath!));
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextFormField(
          controller: issueController,
          decoration: InputDecoration(labelText: 'Report'),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageWidgets.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: imageWidgets),
                ),
              Text('Date: ${DateFormat.yMd().add_jm().format(report.date)}'),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: detailsController,
                decoration: InputDecoration(labelText: 'Details'),
              ),
              TextFormField(
                controller: assignedToController,
                decoration: InputDecoration(labelText: 'Assigned To'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () async {
              final updatedReport = Report(
                id: report.id,
                date: report.date,
                photoPath: report.photoPath,
                section: report.section,
                issue: issueController.text,
                location: locationController.text,
                details: detailsController.text,
                actionRequired: report.actionRequired,
                assignedTo: assignedToController.text,
                projectId: report.projectId,
              );
              await _dbService.insertReport(updatedReport);
              _loadReports(report.projectId);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFullImage(String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageScreen(imagePath: imagePath),
          ),
        );
      },
      child: Hero(
        tag: imagePath,
        child: Image.file(
          File(imagePath),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _navigateToReportScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(camera: widget.camera),
      ),
    );

    if (result != null) {
      final List<String> imagePaths =
          (result['images'] as List<dynamic>).map((e) => e.toString()).toList();
      _createNewReport(imagePaths, result['text']);
    }
  }

  Future<void> _createNewReport(
      List<String> imagePaths, String transcribedText) async {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final currentProject = projectProvider.currentProject;
    final isAiEnabled = await _settingsService.isAiSummaryEnabled();

    if (isAiEnabled) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("AI is processing..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        final StructuredReport structuredReport =
            await _aiService.processTranscribedText(transcribedText);

        final newReport = Report(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          photoPath: jsonEncode(imagePaths),
          section: "General",
          issue: structuredReport.issue,
          location: structuredReport.location,
          details: structuredReport.details,
          actionRequired: "",
          assignedTo: structuredReport.assignedTo,
          projectId: currentProject?.id,
        );

        await _dbService.insertReport(newReport);
        _loadReports(currentProject?.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing report: $e')),
        );
      } finally {
        Navigator.of(context).pop();
      }
    } else {
      final newReport = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        photoPath: jsonEncode(imagePaths),
        section: "General",
        issue: "Voice Note Report",
        location: "",
        details: transcribedText,
        actionRequired: "",
        assignedTo: "",
        projectId: currentProject?.id,
      );

      await _dbService.insertReport(newReport);
      _loadReports(currentProject?.id);
    }
  }

  Future<void> _deleteReport(Report report) async {
    await _dbService.deleteReport(report.id.toString());
    _loadReports(_currentProjectId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report deleted')),
    );
  }

  Future<void> _generateReport(String projectName) async {
    final pdfFile = await _pdfService.generatePdf(_reports, projectName);
    await OpenFile.open(pdfFile.path);
  }
}