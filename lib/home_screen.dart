import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import './models/report.dart';
import './services/database_service.dart';
import './services/pdf_service.dart';
import './services/ai_service.dart';
import './report_screen.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

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
  List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await _dbService.getReports();
    setState(() {
      _reports = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SiteScribe'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generateReport,
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

          return ListTile(
            leading: firstImage != null
                ? Image.file(File(firstImage))
                : null,
            title: Text(report.issue),
            subtitle: Text(report.location),
            onTap: () => _showReportDetails(report),
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
          imageWidgets = imagePaths
              .map((path) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(File(path as String),
                        width: 100, height: 100, fit: BoxFit.cover),
                  ))
              .toList();
        } catch (e) {
          imageWidgets.add(Image.file(File(report.photoPath!)));
        }
      } else {
        imageWidgets.add(Image.file(File(report.photoPath!)));
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextFormField(
          controller: issueController,
          decoration: InputDecoration(labelText: 'Issue'),
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
                actionRequired: report.actionRequired, // This is not editable in this design
                assignedTo: assignedToController.text,
              );
              await _dbService.insertReport(updatedReport);
              _loadReports();
              Navigator.of(context).pop();
            },
          ),
        ],
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
    final newReport = Report(
      id: DateTime.now().toString(),
      date: DateTime.now(),
      photoPath: jsonEncode(imagePaths),
      section: "Electrical",
      issue: transcribedText,
      location: "",
      details: "",
      actionRequired: "",
      assignedTo: "",
    );

    await _dbService.insertReport(newReport);
    _loadReports();
  }

  Future<void> _generateReport() async {
    final pdfFile = await _pdfService.generatePdf(_reports);
    await OpenFile.open(pdfFile.path);
  }
}
