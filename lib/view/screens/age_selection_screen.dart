import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../providers/user_provider.dart';
import 'home_screen.dart';
import 'adult_home_screen.dart';

/// Screen utama untuk memilih kelompok usia (Anak <13 vs Remaja & Dewasa 13+)
/// Dengan animated background shapes yang dinamis
class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen>
    with TickerProviderStateMixin {
  // Fade-in content
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Floating shapes
  late AnimationController _float1Controller;
  late AnimationController _float2Controller;
  late AnimationController _float3Controller;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  late Animation<double> _float1;
  late Animation<double> _float2;
  late Animation<double> _float3;
  late Animation<double> _pulse;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();

    // Content fade in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Floating animations
    _float1Controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _float2Controller = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat(reverse: true);

    _float3Controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _float1 = Tween<double>(begin: 0, end: 18).animate(
      CurvedAnimation(parent: _float1Controller, curve: Curves.easeInOut),
    );
    _float2 = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _float2Controller, curve: Curves.easeInOut),
    );
    _float3 = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _float3Controller, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _float1Controller.dispose();
    _float2Controller.dispose();
    _float3Controller.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) async {
    await SoundService.instance.playClickSound();
    HapticFeedback.mediumImpact();

    final userProvider = context.read<UserProvider>();
    userProvider.setSelectedAgeCategory(category);

    if (!mounted) return;

    if (category == '>=13') {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AdultHomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient Background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEEF2FF),
                  Color(0xFFF8FAFF),
                  Color(0xFFEFF6FF),
                ],
              ),
            ),
          ),

          // ── Animated Background Shapes ──
          AnimatedBuilder(
            animation: Listenable.merge([
              _float1,
              _float2,
              _float3,
              _pulse,
              _rotate,
            ]),
            builder: (context, _) {
              return Stack(
                children: [
                  // Large blob top-left
                  Positioned(
                    top: -60 + _float1.value,
                    left: -60,
                    child: Transform.scale(
                      scale: _pulse.value,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF818CF8).withOpacity(0.18),
                              const Color(0xFF4F46E5).withOpacity(0.04),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Large blob bottom-right
                  Positioned(
                    bottom: -80 + _float2.value,
                    right: -50,
                    child: Transform.scale(
                      scale: 1.1 - (_pulse.value - 0.85),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF3B82F6).withOpacity(0.15),
                              const Color(0xFF2563EB).withOpacity(0.03),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Medium circle top-right
                  Positioned(
                    top: size.height * 0.1 + _float2.value,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFA5B4FC).withOpacity(0.12),
                        border: Border.all(
                          color: const Color(0xFF818CF8).withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Rotating diamond shape center-left
                  Positioned(
                    top: size.height * 0.35 + _float3.value,
                    left: -20,
                    child: Transform.rotate(
                      angle: _rotate.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4F46E5).withOpacity(0.1),
                              const Color(0xFF818CF8).withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF4F46E5).withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Rotating square bottom-left
                  Positioned(
                    bottom: size.height * 0.15 + _float1.value,
                    left: 20,
                    child: Transform.rotate(
                      angle: -_rotate.value * 0.6,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF2563EB).withOpacity(0.08),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Small floating dots
                  ..._buildFloatingDots(size),

                  // Dotted grid pattern top
                  Positioned(
                    top: 60,
                    right: 20,
                    child: Opacity(
                      opacity: 0.15,
                      child: CustomPaint(
                        size: const Size(120, 80),
                        painter: _DotGridPainter(
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ),

                  // Dotted grid pattern bottom
                  Positioned(
                    bottom: 80,
                    left: 20,
                    child: Opacity(
                      opacity: 0.12,
                      child: CustomPaint(
                        size: const Size(100, 70),
                        painter: _DotGridPainter(
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Main Content ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with pulse animation
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulse.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFC7D2FE),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.network(
                            'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/challenges/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.psychology_rounded,
                              size: 40,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.marginM),

                      // App Title
                      Text(
                        'Instrumen Evaluasi REI',
                        style: AppFonts.headlineLarge.copyWith(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Respect • Equity • Inclusion\nSilakan pilih kelompok usia Anda untuk memulai:',
                        style: AppFonts.bodyMedium.copyWith(
                          color: const Color(0xFF475569),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppDimensions.marginXL),

                      // Cards
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                            _buildAdultCard(),
                            const SizedBox(height: AppDimensions.marginL),
                            _buildChildCard(),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.marginXL),

                      Text(
                        'Aplikasi Edukasi & Assesmen REI © 2026',
                        style: AppFonts.bodySmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating small dots scattered around
  List<Widget> _buildFloatingDots(Size size) {
    final dots = [
      _FloatDotConfig(top: size.height * 0.2, left: 30, size: 10, animation: _float1, color: const Color(0xFF818CF8)),
      _FloatDotConfig(top: size.height * 0.5, right: 25, size: 8, animation: _float2, color: const Color(0xFF60A5FA)),
      _FloatDotConfig(top: size.height * 0.7, left: 60, size: 6, animation: _float3, color: const Color(0xFF4F46E5)),
      _FloatDotConfig(top: size.height * 0.25, right: 50, size: 12, animation: _float2, color: const Color(0xFFA5B4FC)),
      _FloatDotConfig(bottom: 120, right: 80, size: 7, animation: _float1, color: const Color(0xFF3B82F6)),
    ];

    return dots.map((d) {
      return Positioned(
        top: d.top,
        bottom: d.bottom,
        left: d.left,
        right: d.right,
        child: AnimatedBuilder(
          animation: d.animation,
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0, d.animation.value),
              child: Container(
                width: d.size,
                height: d.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: d.color.withOpacity(0.4),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildAdultCard() {
    return GestureDetector(
      onTap: () => _selectCategory('>=13'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          border: Border.all(
            color: const Color(0xFF4F46E5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 32,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: const Text(
                          'REMAJA & DEWASA',
                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '13+ Tahun Ke Atas',
                        style: AppFonts.headlineSmall.copyWith(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Modul kuesioner mandiri 45 indikator evaluasi sikap saling menghargai (Respect), kesetaraan (Equity), dan inklusivitas (Inclusion).',
              style: AppFonts.bodySmall.copyWith(
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mulai Assesmen 13+',
                        style: AppFonts.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard() {
    return GestureDetector(
      onTap: () => _selectCategory('<13'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          border: Border.all(
            color: const Color(0xFFBFDBFE),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    size: 32,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Text(
                          'ANAK-ANAK',
                          style: TextStyle(
                            color: Color(0xFF1D4ED8),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Di Bawah 13 Tahun',
                        style: AppFonts.headlineSmall.copyWith(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Permainan kuesioner interaktif dengan gambar, ilustrasi ceria, dan umpan balik edukatif untuk siswa sekolah dasar.',
              style: AppFonts.bodySmall.copyWith(
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mode Anak',
                        style: AppFonts.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Config data untuk floating dot
class _FloatDotConfig {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Animation<double> animation;
  final Color color;

  const _FloatDotConfig({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.animation,
    required this.color,
  });
}

/// Custom painter untuk dot grid pattern dekoratif
class _DotGridPainter extends CustomPainter {
  final Color color;
  _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 16.0;
    const dotRadius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => false;
}
