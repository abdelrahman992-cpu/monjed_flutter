import 'package:flutter/material.dart';
import 'views/home/landing_screen.dart';

void main() {
  runApp(const MonjedApp());
}

class MonjedApp extends StatelessWidget {
  const MonjedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MONJED',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF081214),
        fontFamily: 'Roboto',
      ),
      home: const LandingScreen(),
    );
  }
}

