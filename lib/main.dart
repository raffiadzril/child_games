import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/sound_service.dart';
import 'view/screens/splash_screen.dart';
import 'providers/challenge_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean up any existing sound service instances first
  await SoundService.globalCleanup();

  try {
    await Supabase.initialize(
      url: 'https://jokvxdrxswytjjhxuhvk.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impva3Z4ZHJ4c3d5dGpqaHh1aHZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0MzMwMjIsImV4cCI6MjA2OTAwOTAyMn0.hKilH2syHkxQOnAQ8TlPB7sJOCDRihxzNqv-3MzXgPU',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Supabase: $e');
    // Continue with app even if Supabase fails
  }

  // Initialize sound service
  await SoundService.instance.initialize();
  await SoundService.instance.setVolume(
    0.5,
  ); // Set volume to 50% - not too loud

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add observer untuk lifecycle app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer dan cleanup sound service
    WidgetsBinding.instance.removeObserver(this);
    SoundService.globalCleanup();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        print('App paused - stopping background music');
        SoundService.instance.pauseBackgroundMusic();
        break;
      case AppLifecycleState.resumed:
        print('App resumed - starting background music');
        SoundService.instance.startBackgroundMusic();
        break;
      case AppLifecycleState.inactive:
        print('App inactive - pausing background music');
        SoundService.instance.pauseBackgroundMusic();
        break;
      case AppLifecycleState.detached:
        print('App detached - stopping all audio');
        SoundService.instance.stopBackgroundMusic();
        break;
      case AppLifecycleState.hidden:
        print('App hidden - pausing background music');
        SoundService.instance.pauseBackgroundMusic();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building MyApp with MultiProvider');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            print('Creating ChallengeProvider');
            return ChallengeProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            print('Creating QuizProvider');
            return QuizProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            print('Creating UserProvider');
            return UserProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'REI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        // onGenerateRoute: AppRoutes.generateRoute,
        // initialRoute: AppRoutes.home,
      ),
    );
  }
}
