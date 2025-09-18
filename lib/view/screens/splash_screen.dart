import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../providers/challenge_provider.dart';
import '../widgets/animated_gradient_background.dart';
import 'home_screen.dart';

/// Splash Screen dengan animasi menarik dan loading data aplikasi
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particleController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _particleAnimation;

  String _loadingText = 'Memuat permainan...';
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Particle animation
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );
  }

  Future<void> _startLoadingSequence() async {
    try {
      final start = DateTime.now();
      // Start all animations simultaneously for faster loading
      _logoController.forward();
      _textController.forward();
      _progressController.forward();
      _particleController.repeat();

      // Minimal delay before starting data load
      await Future.delayed(const Duration(milliseconds: 150));

      // Load application data with very short timeout
      try {
        await Future.any([
          _loadApplicationData(),
          Future.delayed(
            const Duration(milliseconds: 1500),
          ), // Very fast timeout
        ]);
      } catch (e) {
        print('Loading sequence timeout or error: $e');
        if (mounted) {
          setState(() {
            _loadingText = 'Siap bermain!';
            _isDataLoaded = true;
          });
        }
      }

      // Ensure splash is visible for about 5 seconds in total from start
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final remain = 5000 - elapsed;
      if (remain > 0) {
        await Future.delayed(Duration(milliseconds: remain));
      }
      _navigateToHome();
    } catch (e) {
      print('Critical error in splash sequence: $e');
      // Emergency navigation
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  Future<void> _navigateToHome() async {
    if (mounted) {
      try {
        // Start background music asynchronously (don't wait for it)
        print('Starting background music...');
        SoundService.instance.startBackgroundMusic().catchError((e) {
          print('Error starting background music: $e');
        });
        print('Background music started');
      } catch (e) {
        print('Error starting background music: $e');
      }

      // Navigate immediately without delay
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(
              milliseconds: 300,
            ), // Even faster transition
          ),
        );
      }
    }
  }

  Future<void> _loadApplicationData() async {
    try {
      setState(() => _loadingText = 'Memuat tantangan...');

      // Load challenges data with very short timeout
      final challengeProvider = context.read<ChallengeProvider>();

      // Try to load challenges very quickly
      try {
        await Future.any([
          challengeProvider.loadChallenges(),
          Future.delayed(
            const Duration(milliseconds: 800),
          ), // Very short timeout
        ]);
        print('Challenges loaded successfully');
      } catch (e) {
        print('Challenge loading failed or timed out: $e');
        // Continue anyway - challenges can be loaded later
      }

      setState(() {
        _loadingText = 'Siap bermain!';
        _isDataLoaded = true;
      });
    } catch (e) {
      print('Error in loading sequence: $e');
      // Even if everything fails, continue to home screen
      setState(() {
        _loadingText = 'Siap bermain!';
        _isDataLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    // Clean dispose without trying to stop music
    print('Splash screen dispose called');

    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // Animated particles
            _buildAnimatedParticles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  _buildAnimatedLogo(),

                  const SizedBox(height: AppDimensions.marginXL),

                  // App title with animation
                  _buildAnimatedTitle(),

                  const SizedBox(height: AppDimensions.marginXL),

                  // Loading progress
                  _buildLoadingProgress(),

                  const SizedBox(height: AppDimensions.marginL),

                  // Loading text
                  _buildLoadingText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _particleController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.network(
                'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/challenges/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.games, size: 60, color: Colors.grey);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Column(
          children: [
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: AppColors.gradientPrimary,
                  ).createShader(bounds),
              child: Text(
                'Respect, Equity, & Inclusion',
                style: AppFonts.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.marginS),
            Text(
              'Belajar sambil bermain!',
              style: AppFonts.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingProgress() {
    return Container(
      width: 200,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.radiusS),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                width: 200 * _progressAnimation.value,
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.gradientPrimary),
                  borderRadius: BorderRadius.circular(AppRadius.radiusS),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _loadingText,
        key: ValueKey(_loadingText),
        style: AppFonts.bodyMedium.copyWith(
          color: _isDataLoaded ? AppColors.success : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Custom painter untuk partikel animasi
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primary.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    // Draw animated particles
    for (int i = 0; i < 20; i++) {
      final double x =
          (size.width * 0.1) +
          (size.width * 0.8) * ((i * 0.1 + animationValue) % 1.0);
      final double y =
          (size.height * 0.2) +
          (size.height * 0.6) * ((i * 0.13 + animationValue * 0.7) % 1.0);
      final double radius = 2 + (i % 3);

      paint.color = AppColors.gradientPrimary[i % 2].withOpacity(0.4);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw floating elements
    for (int i = 0; i < 10; i++) {
      final double x =
          (size.width * 0.05) +
          (size.width * 0.9) * ((i * 0.17 + animationValue * 0.5) % 1.0);
      final double y =
          (size.height * 0.1) +
          (size.height * 0.8) * ((i * 0.23 + animationValue * 0.3) % 1.0);

      paint.color = AppColors.secondary.withOpacity(0.2);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
