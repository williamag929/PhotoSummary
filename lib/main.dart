import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/project_provider.dart';
import 'package:joblog/punch_list_app/services/database_service.dart'
    as punch_list_service;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env"); // Or your custom file name
  } catch (e) {
    // Handle error if .env file loading fails
    //print('Error loading .env file: $e');
  }
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  // Initialize punch list database
  final punchListDatabaseService = punch_list_service.DatabaseService();
  await punchListDatabaseService.initDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectProvider()),
        Provider<punch_list_service.DatabaseService>.value(
            value: punchListDatabaseService),
      ],
      child: MyApp(camera: firstCamera),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Construction Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardScreen(camera: camera),
    );
  }
}
