import 'package:flutter/material.dart';

import 'screens/registration_screen.dart';

void main() {
  runApp(const SkillBridgeApp());
}

class SkillBridgeApp extends StatelessWidget {
  const SkillBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillBridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), 
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const RegistrationScreen(),
    );
  }
}
