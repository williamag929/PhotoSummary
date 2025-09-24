// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

import 'package:photosummary/main.dart';

void main() {
  // It's good practice to initialize the test binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize FFI for sqflite for tests running on desktop.
    sqflite_ffi.sqfliteFfiInit();
    // Use the FFI factory for all database operations in tests.
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app bar title is present.
    expect(find.text('SiteScribe'), findsOneWidget);
    // Also, ensure no exceptions were thrown.
    expect(tester.takeException(), isNull);
  });
}
