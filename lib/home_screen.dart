import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './models/report.dart';
import './services/database_service.dart';
import './services/pdf_service.dart';
import './services/ai_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
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
          return ListTile(
            leading: report.photoPath != null
                ? Image.file(File(report.photoPath!))
                : null,
            title: Text(report.issue),
            subtitle: Text(report.location),
            onTap: () => _showReportDetails(report),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _createNewReport,
      ),
    );
  }

  void _showReportDetails(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.issue),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (report.photoPath != null)
                Image.file(File(report.photoPath!)),
              Text('Date: ${DateFormat.yMd().add_jm().format(report.date)}'),
              Text('Location: ${report.location}'),
              Text('Details: ${report.details}'),
              Text('Action Required: ${report.actionRequired}'),
              Text('Assigned To: ${report.assignedTo}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewReport() async {
    // Step 1: Listen to the Specs (Simulated)
    final spec = await _aiService.getSpec("conduit supports");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(spec)));

    // Step 2: Photo and Voice Memo (Simulated)
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    final transcribedMemo = await _aiService.transcribeVoiceMemo("");

    final newReport = Report(
      id: DateTime.now().toString(),
      date: DateTime.now(),
      photoPath: image?.path,
      section: "Electrical",
      issue: "Non-conformance issue",
      location: transcribedMemo.location,
      details: transcribedMemo.text,
      actionRequired: transcribedMemo.priority,
      assignedTo: transcribedMemo.subcontractor,
    );

    await _dbService.insertReport(newReport);
    _loadReports();
  }

  Future<void> _generateReport() async {
    final pdfFile = await _pdfService.generateReport(_reports);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report generated at ${pdfFile.path}')),
    );
  }
}
