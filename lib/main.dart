import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/sound_service.dart';
import 'routes/app_routes.dart';
import 'view/screens/home_screen.dart';
import 'providers/challenge_provider.dart';
import 'providers/quiz_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jokvxdrxswytjjhxuhvk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impva3Z4ZHJ4c3d5dGpqaHh1aHZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0MzMwMjIsImV4cCI6MjA2OTAwOTAyMn0.hKilH2syHkxQOnAQ8TlPB7sJOCDRihxzNqv-3MzXgPU',
  );

  // Initialize sound service
  await SoundService.instance.initialize();
  await SoundService.instance.setVolume(
    0.5,
  ); // Set volume to 50% - not too loud

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
      child: MaterialApp(
        title: 'Child Games',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        // onGenerateRoute: AppRoutes.generateRoute,
        // initialRoute: AppRoutes.home,
      ),
    );
  }
}
