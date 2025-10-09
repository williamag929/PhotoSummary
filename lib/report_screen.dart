import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';

import '../models/report.dart';
import '../services/ai_service.dart';
import '../services/settings_service.dart';

class ReportScreen extends StatefulWidget {
  final CameraDescription camera;

  const ReportScreen({super.key, required this.camera});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  final List<XFile> _imageFiles = [];
  bool _isTyping = false;
  final TextEditingController _textEditingController = TextEditingController();
  String _textBeforeListen = '';
  bool _isLoading = false;
  ImageAnalysisResult? _analysisResult;
  bool _isAiSummaryEnabled = true;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _speech = stt.SpeechToText();
    _textEditingController.addListener(() {
      setState(() {
        _text = _textEditingController.text;
      });
    });
    _settingsService.isAiSummaryEnabled().then((value) {
      setState(() {
        _isAiSummaryEnabled = value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textEditingController.dispose();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        actions: [
          IconButton(
            icon: Icon(_isTyping ? Icons.mic : Icons.keyboard),
            onPressed: () {
              setState(() {
                _isTyping = !_isTyping;
                if (_isListening) {
                  _stopListen();
                }
              });
            },
          )
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Positioned(
                  bottom: 150,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageFiles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(_imageFiles[index].path),
                            width: 60,
                            height: 60,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if (_isTyping)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _textEditingController,
                            maxLines: 3,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                            decoration: const InputDecoration(
                              hintText: 'Enter report details...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          color: Colors.black54,
                          child: Text(
                            _text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            heroTag: 'camera_fab',
                            onPressed: _takePicture,
                            child: const Icon(Icons.camera_alt),
                          ),
                          if (!_isTyping)
                            FloatingActionButton(
                              heroTag: 'mic_fab',
                              onPressed:
                                  _isListening ? _stopListen : _startListen,
                              child:
                                  Icon(_isListening ? Icons.pause : Icons.mic),
                            ),
                          FloatingActionButton(
                            heroTag: 'check_fab',
                            onPressed: _createReport,
                            child: const Icon(Icons.check),
                          ),
                          if (_isAiSummaryEnabled)
                            FloatingActionButton(
                              heroTag: 'safety_analysis_fab',
                              onPressed: analyzeSafetyImage,
                              child: const Icon(Icons.security),
                            ),
                          //if (_isAiSummaryEnabled)
                          //  FloatingActionButton(
                          //    heroTag: 'quick_check_fab',
                          //    onPressed: quickCheck,
                          //    child: const Icon(Icons.flash_on),
                          //  ),
                          if (_isAiSummaryEnabled)
                            FloatingActionButton(
                              heroTag: 'auto_report_fab',
                              onPressed: () => createReportFromPhoto("On-site"),
                              child: const Icon(Icons.description),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _imageFiles.add(image);
      });
    } catch (e) {
      print(e);
    }
  }

  void _startListen() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _textBeforeListen = _text;
      _speech.listen(
        onResult: (val) => setState(() {
          _text = _textBeforeListen +
              (_textBeforeListen.isNotEmpty ? ' ' : '') +
              val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            // Handle confidence rating if needed
          }
        }),
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        onSoundLevelChange: (level) => print('sound level $level'),
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      print("The user has denied the use of speech recognition.");
    }
  }

  void _stopListen() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _createReport() {
    FocusScope.of(context).unfocus();
    final reportText = _isTyping ? _textEditingController.text : _text;
    if (_imageFiles.isNotEmpty && reportText.isNotEmpty) {
      Navigator.pop(context, {
        'images': _imageFiles.map((e) => e.path).toList(),
        'text': reportText,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please take at least one picture and provide a description.')),
      );
    }
  }

  Future<void> analyzeSafetyImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // Compress to reduce API cost
    );

    if (photo != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        AIService aiService = AIService();
        ImageAnalysisResult result =
            await aiService.analyzeImage(File(photo.path));

        setState(() {
          _analysisResult = result;
          _isLoading = false;
        });

        // Display results
        showResultsDialog(result);
      } catch (e) {
        print("Error: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showResultsDialog(ImageAnalysisResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Safety Analysis'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(result.summary),
              SizedBox(height: 16),
              if (result.hazards.isNotEmpty) ...[
                Text('Hazards:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...result.hazards.map((h) => Text('• $h')),
                SizedBox(height: 16),
              ],
              Text('OSHA Recommendations:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...result.oshaRecommendations.map((r) => Text('• $r')),
              if (result.missingPPE.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Missing PPE:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
                ...result.missingPPE.map(
                    (p) => Text('• $p', style: TextStyle(color: Colors.red))),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> quickCheck() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      AIService aiService = AIService();
      Map<String, dynamic> quickResult =
          await aiService.quickSafetyCheck(File(photo.path));

      // Show quick results
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(quickResult['summary']),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> createReportFromPhoto(String location) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      AIService aiService = AIService();
      StructuredReport report = await aiService.createReportFromImage(
        File(photo.path),
        location,
      );

      // Use the report in your app
      print('Issue: ${report.issue}');
      print('Details: ${report.details}');
      print('Assigned to: ${report.assignedTo}');
      Navigator.pop(context, {
        'images': [photo.path],
        'text': report.details,
        'issue': report.issue,
        'assignedTo': report.assignedTo,
      });
    }
  }
}
