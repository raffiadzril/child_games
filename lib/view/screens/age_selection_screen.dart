import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../providers/user_provider.dart';
import '../widgets/animated_gradient_background.dart';
import 'home_screen.dart';
import 'adult_home_screen.dart';

/// Screen utama untuk memilih kelompok usia (Anak <13 vs Remaja & Dewasa 13+)
class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.network(
                          'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/challenges/logo.png',
                          width: 54,
                          height: 54,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.psychology_rounded,
                              size: 40,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.marginL),

                    // App Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFE0E7FF)],
                      ).createShader(bounds),
                      child: Text(
                        'Respect, Equity, & Inclusion',
                        style: AppFonts.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.marginS),

                    Text(
                      'Selamat datang! Silakan pilih kategori usia untuk memulai:',
                      style: AppFonts.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.marginXL),

                    // Cards Container
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        children: [
                          // Child Option Card (< 13 Years)
                          _buildChildCard(),

                          const SizedBox(height: AppDimensions.marginL),

                          // Adult Option Card (13+ Years)
                          _buildAdultCard(),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.marginXL),

                    Text(
                      'Aplikasi Edukasi & Assesmen REI © 2026',
                      style: AppFonts.bodySmall.copyWith(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B73FF).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ANAK-ANAK',
                          style: TextStyle(
                            color: Colors.black87,
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
                          color: Colors.white,
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
              'Permainan kuesioner interaktif dengan gambar, ilustrasi ceria, dan feedback seru untuk anak-anak sekolah dasar.',
              style: AppFonts.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.92),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mulai Main',
                        style: AppFonts.labelMedium.copyWith(
                          color: const Color(0xFF000DFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Color(0xFF000DFF),
                      ),
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

  Widget _buildAdultCard() {
    return GestureDetector(
      onTap: () => _selectCategory('>=13'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF311B92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF311B92).withOpacity(0.5),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF818CF8).withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF818CF8).withOpacity(0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 36,
                    color: Color(0xFFA5B4FC),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'REMAJA & DEWASA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '13 Tahun Ke Atas',
                        style: AppFonts.headlineSmall.copyWith(
                          color: Colors.white,
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
              'Modul Assesmen REI profesional untuk usia 13+ tahun. Evaluasi mendalam indikator Respect, Equity, & Inclusion dengan skala respon 5 tingkat.',
              style: AppFonts.bodySmall.copyWith(
                color: const Color(0xFFC7D2FE),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Masuk Assesmen 13+',
                        style: AppFonts.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
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
