import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/challenge_model.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/user_provider.dart';
import '../widgets/biodata_dialog.dart';
import 'quiz_screen.dart';
import 'age_selection_screen.dart';

/// Screen Dashboard Utama Khusus Kategori Remaja & Dewasa (13+ Tahun)
/// Tampilan Bersih (Light Mode) Professional
class AdultHomeScreen extends StatefulWidget {
  const AdultHomeScreen({super.key});

  @override
  State<AdultHomeScreen> createState() => _AdultHomeScreenState();
}

class _AdultHomeScreenState extends State<AdultHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = context.read<ChallengeProvider>();
        provider.loadChallenges();
      } catch (e) {
        print('AdultHomeScreen: Error loading challenges: $e');
      }
    });
  }

  void _switchAgeCategory() async {
    await SoundService.instance.playClickSound();
    HapticFeedback.lightImpact();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AgeSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _startAdultAssessment(ChallengeModel challenge) {
    final userProvider = context.read<UserProvider>();

    if (userProvider.isUserLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(challenge: challenge),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BiodataDialog(
          onSuccess: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(challenge: challenge),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Clean white/slate background
      body: SafeArea(
        child: Column(
          children: [
            // Adult Header Bar
            _buildAdultHeader(),

            // Main Body Content
            Expanded(
              child: Consumer<ChallengeProvider>(
                builder: (context, challengeProvider, child) {
                  if (challengeProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4F46E5),
                        ),
                      ),
                    );
                  }

                  // Find adult challenge (Assesmen REI 13+)
                  late ChallengeModel adultChallenge;
                  try {
                    adultChallenge = challengeProvider.challenges.firstWhere(
                      (c) =>
                          c.id == 'a1b2c3d4-e5f6-7890-abcd-131313131313' ||
                          c.title.contains('13+'),
                    );
                  } catch (_) {
                    adultChallenge = ChallengeModel(
                      id: 'a1b2c3d4-e5f6-7890-abcd-131313131313',
                      title: 'Assesmen REI (13+ Tahun)',
                      description: 'Kuesioner Respect, Equity, & Inclusion untuk usia 13 tahun ke atas',
                      category: 'REI 13+',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Banner
                        _buildWelcomeBanner(),

                        const SizedBox(height: AppDimensions.marginXL),

                        // Adult Challenge Hero Card
                        _buildAdultAssessmentCard(adultChallenge),

                        const SizedBox(height: AppDimensions.marginXL),

                        // Indicators Section Header
                        Text(
                          'Indikator Utama Evaluasi',
                          style: AppFonts.titleLarge.copyWith(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '3 pilar nilai utama yang dievaluasi dalam instrumen ini:',
                          style: AppFonts.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.marginM),

                        // 3 Pilar Cards
                        _buildPillarCards(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdultHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo & Category Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(AppRadius.radiusM),
              border: Border.all(
                color: const Color(0xFFC7D2FE),
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.network(
              'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/challenges/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.shield_outlined,
                color: Color(0xFF4F46E5),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modul Evaluasi REI',
                  style: AppFonts.titleMedium.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kategori 13+ Tahun (Remaja & Dewasa)',
                  style: AppFonts.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Switch Age Button
          GestureDetector(
            onTap: _switchAgeCategory,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppRadius.radiusM),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: Color(0xFF334155),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Ganti Usia',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(AppRadius.radiusL),
        border: Border.all(
          color: const Color(0xFFC7D2FE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF4338CA),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'INSTRUMEN ASSESMEN RESMI',
                style: AppFonts.labelMedium.copyWith(
                  color: const Color(0xFF4338CA),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Assesmen Respect, Equity, & Inclusion',
            style: AppFonts.headlineMedium.copyWith(
              color: const Color(0xFF1E1B4B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kuesioner evaluasi ini dirancang untuk menganalisis persepsi, sikap, dan tindakan penerapan nilai-nilai keberagaman, kesetaraan, dan inklusi sosial.',
            style: AppFonts.bodySmall.copyWith(
              color: const Color(0xFF3730A3),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdultAssessmentCard(ChallengeModel challenge) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.radiusXL),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFA7F3D0),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF065F46),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'MODUL AKTIF',
                        style: TextStyle(
                          color: Color(0xFF065F46),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '13+ Tahun',
                  style: AppFonts.labelMedium.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              challenge.title,
              style: AppFonts.headlineSmall.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              challenge.description,
              style: AppFonts.bodyMedium.copyWith(
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // Metadata Chips
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildMetaChip(Icons.quiz_outlined, '45 Pertanyaan Evaluasi'),
                _buildMetaChip(
                  Icons.linear_scale_rounded,
                  'Skala Pilihan A - E',
                ),
                _buildMetaChip(
                  Icons.bar_chart_rounded,
                  'Skor & Analisis REI',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Big CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _startAdultAssessment(challenge),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radiusM),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Mulai Assesmen REI (13+)',
                      style: AppFonts.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppRadius.radiusS),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCards() {
    final pillars = [
      {
        'title': 'Respect (Rasa Hormat)',
        'desc':
            'Penghargaan terhadap harkat diri sendiri serta menghormati perbedaan hak milik dan latar belakang sesama.',
        'icon': Icons.favorite_border_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'Equity (Keadilan)',
        'desc':
            'Sikap adil, tidak diskriminatif, dan mengutamakan kesempatan bersama secara setara.',
        'icon': Icons.balance_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'title': 'Inclusion (Inklusi)',
        'desc':
            'Kemampuan merangkul dan mengajak semua pihak tanpa menyisihkan kelompok manapun.',
        'icon': Icons.groups_outlined,
        'color': const Color(0xFF059669),
      },
    ];

    return Column(
      children: pillars.map((p) {
        final color = p['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.marginM),
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.radiusM),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  p['icon'] as IconData,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title'] as String,
                      style: AppFonts.titleSmall.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p['desc'] as String,
                      style: AppFonts.bodySmall.copyWith(
                        color: const Color(0xFF475569),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(ChallengeProvider challengeProvider) {
    return Center(
      child: Column(
        children: [
          Text(
            challengeProvider.hasError
                ? (challengeProvider.errorMessage ?? 'Gagal memuat data')
                : 'Belum ada data modul 13+',
            style: const TextStyle(color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => challengeProvider.loadChallenges(),
            child: const Text('Coba Muat Ulang'),
          ),
        ],
      ),
    );
  }
}
