import 'package:child_games/view/screens/home_screen.dart';
import 'package:flutter/material.dart';

/// Kelas untuk mengelola routes aplikasi
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String gameMenu = '/game-menu';
  static const String gameDetail = '/game-detail';
  static const String gamePlay = '/game-play';
  static const String leaderboard = '/leaderboard';
  static const String achievements = '/achievements';
  static const String settingsPage = '/settings';
  static const String about = '/about';

  /// Map routes ke widgets
  static Map<String, WidgetBuilder> get routes => {
    // splash: (context) => const SplashScreen(),
    // home: (context) => const HomeScreen(),
    // login: (context) => const LoginScreen(),
    // register: (context) => const RegisterScreen(),
    // profile: (context) => const ProfileScreen(),
    // gameMenu: (context) => const GameMenuScreen(),
    // gameDetail: (context) => const GameDetailScreen(),
    // gamePlay: (context) => const GamePlayScreen(),
    // leaderboard: (context) => const LeaderboardScreen(),
    // achievements: (context) => const AchievementsScreen(),
    // settings: (context) => const SettingsScreen(),
    // about: (context) => const AboutScreen(),
  };

  /// Generate route untuk dynamic routing
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Splash Screen'))),
        );
      // ROUTE KE HOME
      case home:
        return MaterialPageRoute(
          builder:
              (context) => const HomeScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Login Screen'))),
        );
      case register:
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Register Screen'))),
        );
      case profile:
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Profile Screen'))),
        );
      case gameMenu:
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Game Menu Screen'))),
        );
      case gameDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: Text('Game Detail Screen\nArgs: ${args.toString()}'),
                ),
              ),
        );
      case gamePlay:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: Text('Game Play Screen\nArgs: ${args.toString()}'),
                ),
              ),
        );
      case leaderboard:
        return MaterialPageRoute(
          builder:
              (context) => const Scaffold(
                body: Center(child: Text('Leaderboard Screen')),
              ),
        );
      case achievements:
        return MaterialPageRoute(
          builder:
              (context) => const Scaffold(
                body: Center(child: Text('Achievements Screen')),
              ),
        );
      case settingsPage:
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Settings Screen'))),
        );
      case about:
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('About Screen'))),
        );
      default:
        return MaterialPageRoute(
          builder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Page Not Found'))),
        );
    }
  }

  /// Method helper untuk navigasi
  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void goBackWithResult(BuildContext context, dynamic result) {
    Navigator.pop(context, result);
  }
}
