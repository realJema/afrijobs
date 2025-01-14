import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/filter_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_job_screen.dart';
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
  
  final filterProvider = FilterProvider();
  await filterProvider.initializeFilterData();

  final profileProvider = ProfileProvider();
  await profileProvider.loadProfile();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FilterProvider>.value(value: filterProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
      ],
      child: const AfriJobsApp(),
    ),
  );
}

class AfriJobsApp extends StatelessWidget {
  const AfriJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfriJobs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D4A3E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D4A3E),
          primary: const Color(0xFF2D4A3E),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/add-job': (context) => const AddJobScreen(),
      },
    );
  }
}
