import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
//import 'package:aws_s3_upload/aws_s3_upload.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File? _image;
  String _analysisResult = '';
  String _summary = '';
  final picker = ImagePicker();
  final String awsS3Bucket = 'your-bucket-name'; // Replace with your S3 bucket
  final String awsRegion = 'us-east-1'; // Replace with your AWS region
  final String lambdaImageUrl = 'https://your-lambda-image-endpoint'; // Replace with Lambda endpoint
  final String lambdaSummaryUrl = 'https://your-lambda-summary-endpoint'; // Replace with Lambda endpoint
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pick image and upload to S3
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null && mounted) {
      setState(() {
        _image = File(pickedFile.path);
      });
      String photoUrl = '';//await _uploadToS3(_image!);
      await _analyzeImage(photoUrl);
    }
  }

  // Upload image to S3
//  Future<String> _uploadToS3(File image) async {
//    final fileName = 'photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
//    await AwsS3.uploadFile(
//      accessKey: 'YOUR_AWS_ACCESS_KEY',
//      secretKey: 'YOUR_AWS_SECRET_KEY',
//      file: image,
//      bucket: awsS3Bucket,
//      region: awsRegion,
//      destDir: 'photos',
//      filename: fileName,
//    );
//    return 'https://$awsS3Bucket.s3.$awsRegion.amazonaws.com/$fileName';
//  }

  // Call Lambda for YOLO image analysis
  Future<void> _analyzeImage(String photoUrl) async {
    try {
      final response = await http.post(
        Uri.parse(lambdaImageUrl),
        headers: {'Content-Type': 'application/json'},
        body: '{"photo_url": "$photoUrl"}',
      );
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _analysisResult = response.body; // e.g., "Detected: 2 helmets, 1 excavator"
        });
        await _savePhotoMetadata(photoUrl, _analysisResult);
        await _summarizeAnalysis(_analysisResult);
      } else {
        setState(() {
          _analysisResult = 'Error analyzing image: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisResult = 'Error: $e';
        });
      }
    }
  }

  // Save photo metadata and analysis to Firestore
  Future<void> _savePhotoMetadata(String photoUrl, String analysis) async {
    final photoId = _firestore.collection('photo').doc().id;
    await _firestore.collection('photo').doc(photoId).set({
      'photo_id': photoId,
      'url': photoUrl,
      'project_id': 'sample_project_id', // Replace with actual project ID
      'timestamp': Timestamp.now(),
    });
    await _firestore.collection('summary_photo').doc().set({
      'photo_id': photoId,
      'analysis': analysis,
      'timestamp': Timestamp.now(),
    });
  }

  // Call Lambda for xAI summarization
  Future<void> _summarizeAnalysis(String analysis) async {
    try {
      final response = await http.post(
        Uri.parse(lambdaSummaryUrl),
        headers: {'Content-Type': 'application/json'},
        body: '{"text": "$analysis"}',
      );
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _summary = response.body; // e.g., "Summary: 2 helmets and 1 excavator detected"
        });
        await _firestore.collection('notes').doc().set({
          'project_id': 'sample_project_id', // Replace with actual project ID
          'content': _summary,
          'timestamp': Timestamp.now(),
        });
      } else {
        setState(() {
          _summary = 'Error summarizing: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _summary = 'Error: $e';
        });
      }
    }
  }


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Take Photo'),
            ),
            if (_image != null)
              Image.file(_image!, height: 200),
            Text('Analysis: $_analysisResult'),
            Text('Summary: $_summary'),
          ],
        ),
      ),
      //floatingActionButton: FloatingActionButton(
      //  onPressed: _incrementCounter,
      //  tooltip: 'Increment',
      //  child: const Icon(Icons.add),
      //), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
