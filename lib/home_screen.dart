import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import './screens/project_management_screen.dart';
import './screens/settings_screen.dart';
import './screens/full_screen_image_screen.dart';
import './screens/calendar_screen.dart';
import './constants/app_theme.dart';
import './utils/platform_widgets.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;
  final DateTime? selectedDate;

  const HomeScreen({super.key, required this.camera, this.selectedDate});

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
  bool _isCalendarViewEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    if (widget.selectedDate != null) {
      _loadReportsForDate(widget.selectedDate!);
    } else {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);
      projectProvider.fetchProjects().then((_) {
        if (projectProvider.currentProject != null) {
          _loadReports(projectProvider.currentProject!.id);
        } else {
          _loadReports(null);
        }
      });
    }
  }

  Future<void> _loadSettings() async {
    final isCalendarEnabled = await _settingsService.isCalendarViewEnabled();
    if (!mounted) return;
    setState(() {
      _isCalendarViewEnabled = isCalendarEnabled;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.selectedDate == null) {
      final projectProvider = Provider.of<ProjectProvider>(context);
      if (_currentProjectId != projectProvider.currentProject?.id) {
        _currentProjectId = projectProvider.currentProject?.id;
        _loadReports(_currentProjectId);
      }
    }
  }

  Future<void> _loadReports(int? projectId) async {
    final reports = await _dbService.getReports(projectId: projectId);
    if (!mounted) return;
    setState(() {
      _reports = reports;
    });
  }

  Future<void> _loadReportsForDate(DateTime date) async {
    final reports = await _dbService.getReportsByDate(date);
    if (!mounted) return;
    setState(() {
      _reports = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final currentProject = projectProvider.currentProject;
    final isIOS = Platform.isIOS;

    return Scaffold(
      backgroundColor: isIOS ? AppTheme.backgroundColor : null,
      appBar: AppBar(
        title: Text(widget.selectedDate != null
            ? DateFormat.yMMMMd().format(widget.selectedDate!)
            : currentProject?.name ?? 'JobLog'),
        actions: [
          if (widget.selectedDate == null)
            IconButton(
              icon: const Icon(Icons.folder),
              onPressed: () {
                PlatformWidgets.lightHaptic();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProjectManagementScreen()),
                );
              },
            ),
          if (_isCalendarViewEnabled && widget.selectedDate == null)
            IconButton(
              icon: const Stack(
                children: [
                  Icon(Icons.calendar_today),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.star, color: Colors.yellow, size: 12),
                  ),
                ],
              ),
              onPressed: () {
                PlatformWidgets.lightHaptic();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalendarScreen(
                          camera: widget.camera, projectId: _currentProjectId)),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              PlatformWidgets.lightHaptic();
              _generateReport(currentProject?.name ?? "Unknown Project");
            },
          ),
          if (widget.selectedDate == null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                PlatformWidgets.lightHaptic();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                ).then((_) => _loadSettings());
              },
            ),
        ],
      ),
      body: _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    'No reports yet',
                    style: AppTheme.title2Style
                        .copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Tap the camera button to create one',
                    style: AppTheme.subheadStyle
                        .copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(isIOS ? AppTheme.spacing16 : 0),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                String? firstImage;
                if (report.photoPath != null) {
                  if (report.photoPath!.startsWith('[')) {
                    try {
                      final List<dynamic> imagePaths =
                          jsonDecode(report.photoPath!);
                      if (imagePaths.isNotEmpty) {
                        firstImage = imagePaths.first as String;
                      }
                    } catch (e) {
                      firstImage =
                          report.photoPath; // Fallback for single image path
                    }
                  } else {
                    firstImage = report.photoPath;
                  }
                }

                return Dismissible(
                  key: Key(report.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: isIOS
                        ? EdgeInsets.only(bottom: AppTheme.spacing12)
                        : null,
                    decoration: BoxDecoration(
                      color: AppTheme.destructiveColor,
                      borderRadius: isIOS
                          ? BorderRadius.circular(AppTheme.radiusMedium)
                          : null,
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    PlatformWidgets.mediumHaptic();
                    _deleteReport(report);
                  },
                  confirmDismiss: (direction) async {
                    PlatformWidgets.lightHaptic();
                    return await PlatformWidgets.showConfirmDialog(
                      context: context,
                      title: "Confirm",
                      content: "Are you sure you wish to delete this report?",
                      confirmText: "Delete",
                      cancelText: "Cancel",
                      isDestructive: true,
                    );
                  },
                  child: _buildReportCard(report, firstImage, isIOS),
                );
              },
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildReportCard(Report report, String? firstImage, bool isIOS) {
    return Container(
      margin: isIOS ? const EdgeInsets.only(bottom: AppTheme.spacing12) : null,
      decoration: isIOS
          ? BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            )
          : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              isIOS ? BorderRadius.circular(AppTheme.radiusMedium) : null,
          onTap: () {
            PlatformWidgets.lightHaptic();
            _showReportDetails(report);
          },
          child: Padding(
            padding: EdgeInsets.all(isIOS ? AppTheme.spacing12 : 8.0),
            child: Row(
              children: [
                if (firstImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: Image.file(
                      File(firstImage),
                      width: isIOS ? 60 : 56,
                      height: isIOS ? 60 : 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.issue,
                        style: isIOS ? AppTheme.headlineStyle : null,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (report.location.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          report.location,
                          style: isIOS
                              ? AppTheme.subheadStyle
                                  .copyWith(color: Colors.grey.shade600)
                              : Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        DateFormat.yMd().add_jm().format(report.date),
                        style: isIOS
                            ? AppTheme.footnoteStyle
                                .copyWith(color: Colors.grey.shade500)
                            : Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (isIOS)
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    // The camera plugin doesn't support desktop, so hide the FAB.
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      return FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: _navigateToReportScreen,
        child: const Icon(Icons.add_a_photo),
      );
    }
    return null;
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
          decoration: const InputDecoration(labelText: 'Report'),
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
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: 'Details'),
              ),
              TextFormField(
                controller: assignedToController,
                decoration: const InputDecoration(labelText: 'Assigned To'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
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
              if (widget.selectedDate != null) {
                _loadReportsForDate(widget.selectedDate!);
              } else {
                _loadReports(report.projectId);
              }
              if (mounted) {
                Navigator.of(context).pop();
              }
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
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    final currentProject = projectProvider.currentProject;
    final isAiEnabled = await _settingsService.isAiSummaryEnabled();

    if (isAiEnabled) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
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
        if (widget.selectedDate != null) {
          _loadReportsForDate(widget.selectedDate!);
        } else {
          _loadReports(currentProject?.id);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error processing report: $e')),
          );
        }
      } finally {
        if (mounted) {
          Navigator.of(context).pop();
        }
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
      if (widget.selectedDate != null) {
        _loadReportsForDate(widget.selectedDate!);
      } else {
        _loadReports(currentProject?.id);
      }
    }
  }

  Future<void> _deleteReport(Report report) async {
    await _dbService.deleteReport(report.id.toString());
    if (widget.selectedDate != null) {
      _loadReportsForDate(widget.selectedDate!);
    } else {
      _loadReports(_currentProjectId);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report deleted')),
    );
  }

  Future<void> _generateReport(String projectName) async {
    final isAiEnabled = await _settingsService.isAiSummaryEnabled();
    AISummary? aiSummary;
    Map<String, List<String>> safetyViolations = {};

    if (isAiEnabled) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("AI is summarizing..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        aiSummary = await _aiService.generateReportSummary(_reports);
        for (var report in _reports) {
          final violations = await _aiService.checkForSafetyViolations(report);
          if (violations.isNotEmpty) {
            safetyViolations[report.id.toString()] = violations;
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating AI summary: $e')),
          );
        }
      } finally {
        if (mounted) {
          Navigator.of(context).pop(); // Close the progress dialog
        }
      }
    }

    final pdfFile = await _pdfService.generatePdf(
      _reports,
      projectName,
      aiSummary: aiSummary,
      safetyViolations: safetyViolations,
    );
    await OpenFile.open(pdfFile.path);
  }
}
