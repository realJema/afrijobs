import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AfriJobsApp());
}

class AfriJobsApp extends StatelessWidget {
  const AfriJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfriJobs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D4B4D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D4B4D),
          primary: const Color(0xFF2D4B4D),
        ),
        // Using system fonts instead of Google Fonts
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
