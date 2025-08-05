import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/fonts.dart';
import '../../core/services/sound_service.dart';
import '../widgets/challenges_grid.dart';
import '../widgets/animated_gradient_background.dart';

/// Home screen dengan challenge cards dan animated background
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isMusicPlaying = true;

  @override
  void initState() {
    super.initState();
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Ensure music is playing when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartMusic();
    });
  }

  void _checkAndStartMusic() async {
    try {
      // Simple approach: just enable and start music
      SoundService.instance.setMusicEnabled(true);

      // Small delay to ensure service is ready
      await Future.delayed(const Duration(milliseconds: 200));

      // Start music
      await SoundService.instance.startBackgroundMusic();
      print('Music started successfully');

      if (mounted) {
        setState(() {
          _isMusicPlaying = SoundService.instance.isMusicEnabled;
        });
      }
    } catch (e) {
      print('Error starting music: $e');
    }
  }

  void _toggleMusic() {
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });

    if (_isMusicPlaying) {
      SoundService.instance.setMusicEnabled(true);
      SoundService.instance
          .startBackgroundMusic(); // Use startBackgroundMusic instead of resume
    } else {
      SoundService.instance.setMusicEnabled(false);
      SoundService.instance.pauseBackgroundMusic();
    }
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    print('HomeScreen dispose called');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Update UI state based on app lifecycle
    if (mounted) {
      switch (state) {
        case AppLifecycleState.resumed:
          setState(() {
            _isMusicPlaying = SoundService.instance.isMusicEnabled;
          });
          break;
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          // Don't update UI when app is paused/inactive, just let lifecycle handle audio
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom colorful app bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // Logo/Icon dengan animasi
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 0.5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.accent1, AppColors.accent3],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent1.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.games,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),

                    // Title dengan gradient text
                    Expanded(
                      child: ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ).createShader(bounds),
                        child: Text(
                          'Child Games',
                          style: AppFonts.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Animated stars
                    ...List.generate(3, (index) {
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 1000 + (index * 200)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.5 + (value * 0.5),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.star,
                                  color:
                                      [
                                        AppColors.accent1,
                                        AppColors.accent2,
                                        AppColors.accent5,
                                      ][index],
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    const SizedBox(width: 16),

                    // Music toggle button
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: GestureDetector(
                            onTap: _toggleMusic,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      _isMusicPlaying
                                          ? [
                                            AppColors.success,
                                            AppColors.accent4,
                                          ]
                                          : [
                                            AppColors.textSecondary,
                                            AppColors.border,
                                          ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isMusicPlaying
                                            ? AppColors.success
                                            : AppColors.textSecondary)
                                        .withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isMusicPlaying
                                    ? Icons.music_note
                                    : Icons.music_off,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Challenges grid dengan background transparan
              const Expanded(child: ChallengesGrid()),
            ],
          ),
        ),
      ),
    );
  }
}
