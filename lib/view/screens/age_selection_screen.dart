import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../providers/user_provider.dart';
import 'home_screen.dart';
import 'adult_home_screen.dart';

/// Screen utama untuk memilih kelompok usia (Anak <13 vs Remaja & Dewasa 13+)
/// Tema Terang Bersih (Clean Light Mode) Background Putih
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
      backgroundColor: const Color(0xFFF8FAFC), // Clean white/slate background
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon Header
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC7D2FE),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F4F46E5),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.psychology_rounded,
                        size: 40,
                        color: Color(0xFF4F46E5),
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

                  // Cards Container
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        // Adult Option Card (13+ Years) - Recommended First
                        _buildAdultCard(),

                        const SizedBox(height: AppDimensions.marginL),

                        // Child Option Card (< 13 Years)
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
    );
  }

  Widget _buildAdultCard() {
    return GestureDetector(
      onTap: () => _selectCategory('>=13'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          border: Border.all(
            color: const Color(0xFF4F46E5),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A4F46E5),
              blurRadius: 16,
              offset: Offset(0, 6),
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
                    border: Border.all(
                      color: const Color(0xFFC7D2FE),
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFC7D2FE),
                          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x294F46E5),
                        blurRadius: 8,
                        offset: Offset(0, 2),
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

  Widget _buildChildCard() {
    return GestureDetector(
      onTap: () => _selectCategory('<13'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
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
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mode Anak',
                        style: AppFonts.labelMedium.copyWith(
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: const Color(0xFF334155),
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
