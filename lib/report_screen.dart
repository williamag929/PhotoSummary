import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';

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
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            decoration: const InputDecoration(
                              hintText: 'Enter report details...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          color: Colors.black54,
                          child: Text(
                            _text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
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
                              onPressed: _isListening ? _stopListen : _startListen,
                              child: Icon(_isListening ? Icons.pause : Icons.mic),
                            ),
                          FloatingActionButton(
                            heroTag: 'check_fab',
                            onPressed: _createReport,
                            child: const Icon(Icons.check),
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
          //_text = val.recognizedWords;
          _text = _textBeforeListen + (_textBeforeListen.isNotEmpty ? ' ' : '') + val.recognizedWords;
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
        const SnackBar(content: Text('Please take at least one picture and provide a description.')),
      );
    }
  }
}