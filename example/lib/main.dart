import 'package:example/app_colors.dart';
import 'package:example/face_registration_detector.dart';
import 'package:example/registration.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppThemes.dark,
      home: RegisterFaceScreen(),
    );
  }
}
