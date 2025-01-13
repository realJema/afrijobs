import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: true, // Enable debug mode
    );
    print('Supabase initialized successfully');
    print('URL: ${SupabaseConfig.url}');
  } catch (e) {
    print('Error initializing Supabase: $e');
  }
  
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
