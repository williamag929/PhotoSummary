import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';

class ReportScreen extends StatefulWidget {
  final CameraDescription camera;

  const ReportScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  XFile? _imageFile;
  bool _isTyping = false;
  final TextEditingController _textEditingController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Report'),
        actions: [
          IconButton(
            icon: Icon(_isTyping ? Icons.mic : Icons.keyboard),
            onPressed: () {
              setState(() {
                _isTyping = !_isTyping;
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
                if (_imageFile != null)
                  Positioned(
                    bottom: 80,
                    left: 20,
                    child: Image.file(
                      File(_imageFile!.path),
                      width: 60,
                      height: 60,
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
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _textEditingController,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            decoration: InputDecoration(
                              hintText: 'Enter report details...',
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      else
                        Text(
                          _text,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            heroTag: 'camera_fab',
                            onPressed: _takePicture,
                            child: Icon(Icons.camera_alt),
                          ),
                          if (!_isTyping)
                            FloatingActionButton(
                              heroTag: 'mic_fab',
                              onPressed: _listen,
                              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                            ),
                          FloatingActionButton(
                            heroTag: 'check_fab',
                            onPressed: _createReport,
                            child: Icon(Icons.check),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
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
        _imageFile = image;
      });
    } catch (e) {
      print(e);
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _createReport() {
    if (_imageFile != null && _text.isNotEmpty) {
      Navigator.pop(context, {'image': _imageFile, 'text': _text});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please take a picture and add a description.')),
      );
    }
  }
}
