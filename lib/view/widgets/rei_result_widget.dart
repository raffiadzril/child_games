import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/rei_accumulate_model.dart';
import 'colorful_card.dart';

/// Widget untuk menampilkan hasil REI (Respect, Equity, Inclusion)
class ReiResultWidget extends StatefulWidget {
  final ReiAccumulateModel reiResult;
  final VoidCallback? onContinue;

  const ReiResultWidget({super.key, required this.reiResult, this.onContinue});

  @override
  State<ReiResultWidget> createState() => _ReiResultWidgetState();
}

class _ReiResultWidgetState extends State<ReiResultWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _barController;
  late AnimationController _pulseController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _barAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _barController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _barAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeInOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _barController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _barController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            // Header dengan animasi pulse
            _buildHeader(),

            const SizedBox(height: AppDimensions.marginL),

            // Score cards
            _buildScoreCards(),

            const SizedBox(height: AppDimensions.marginL),

            // Progress bars
            _buildProgressBars(),

            const SizedBox(height: AppDimensions.marginL),

            // Summary
            _buildSummary(),

            const SizedBox(height: AppDimensions.marginXL),

            // Continue button
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Column(
            children: [
              // Trophy icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppDimensions.marginM),

              // Title
              ShaderMask(
                shaderCallback:
                    (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ).createShader(bounds),
                child: Text(
                  'Hasil REI Kamu!',
                  style: AppFonts.displayMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppDimensions.marginS),

              Text(
                'Respect • Equity • Inclusion',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreCards() {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard('Respect', widget.reiResult.respect, const [
            Color(0xFF6B73FF),
            Color(0xFF9BA3FF),
          ], Icons.favorite),
        ),
        const SizedBox(width: AppDimensions.marginM),
        Expanded(
          child: _buildScoreCard('Equity', widget.reiResult.equity, const [
            Color(0xFF4ECDC4),
            Color(0xFF44A08D),
          ], Icons.balance),
        ),
        const SizedBox(width: AppDimensions.marginM),
        Expanded(
          child: _buildScoreCard(
            'Inclusion',
            widget.reiResult.inclusion,
            const [Color(0xFFFF9F43), Color(0xFFFFD93D)],
            Icons.group,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    String title,
    int score,
    List<Color> gradient,
    IconData icon,
  ) {
    return ColorfulCard(
      gradient: gradient,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: AppDimensions.marginS),
            Text(
              title,
              style: AppFonts.labelMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginXS),
            TweenAnimationBuilder<int>(
              duration: const Duration(milliseconds: 1500),
              tween: IntTween(begin: 0, end: score),
              builder: (context, value, child) {
                return Text(
                  value.toString(),
                  style: AppFonts.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    final percentages = widget.reiResult.categoryPercentages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribusi Skor',
          style: AppFonts.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.marginM),

        _buildProgressBar(
          'Respect',
          percentages['respect']! / 100,
          const Color(0xFF6B73FF),
          widget.reiResult.respect,
        ),
        const SizedBox(height: AppDimensions.marginM),

        _buildProgressBar(
          'Equity',
          percentages['equity']! / 100,
          const Color(0xFF4ECDC4),
          widget.reiResult.equity,
        ),
        const SizedBox(height: AppDimensions.marginM),

        _buildProgressBar(
          'Inclusion',
          percentages['inclusion']! / 100,
          const Color(0xFFFF9F43),
          widget.reiResult.inclusion,
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    String label,
    double percentage,
    Color color,
    int score,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}% ($score)',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginXS),

        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppRadius.radiusS),
          ),
          child: AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage * _barAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadius.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final r = widget.reiResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Overall summary card
        ColorfulCard(
          gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                Text(
                  'Kategori Tertinggi',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginS),
                Text(
                  r.highestCategory,
                  style: AppFonts.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginS),
                Text(
                  'Total Skor: ${r.totalScore}',
                  style: AppFonts.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if ((r.allCategory ?? r.labelAnakRamahCategory) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.marginM),
                    child: Text(
                      (r.allCategory ?? r.labelAnakRamahCategory)!,
                      style: AppFonts.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (r.allNote != null && r.allNote!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.marginS),
                    child: Text(
                      r.allNote!,
                      style: AppFonts.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.marginL),

        // Category details grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            final children = <Widget>[
              _buildCategoryDetailCard(
                title: 'Respect',
                gradient: const [Color(0xFF6B73FF), Color(0xFF9BA3FF)],
                category: r.respectCategory,
                note: r.respectNote,
                label: r.labelAnakRamahCategoryRespect,
                icon: Icons.favorite,
              ),
              _buildCategoryDetailCard(
                title: 'Equity',
                gradient: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                category: r.equityCategory,
                note: r.equityNote,
                label: r.labelAnakRamahCategoryEquity,
                icon: Icons.balance,
              ),
              _buildCategoryDetailCard(
                title: 'Inclusion',
                gradient: const [Color(0xFFFF9F43), Color(0xFFFFD93D)],
                category: r.inclusionCategory,
                note: r.inclusionNote,
                label: r.labelAnakRamahCategoryInclusion,
                icon: Icons.group,
              ),
            ];

            if (isNarrow) {
              return Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1)
                      const SizedBox(height: AppDimensions.marginM),
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: AppDimensions.marginM),
                Expanded(child: children[1]),
                const SizedBox(width: AppDimensions.marginM),
                Expanded(child: children[2]),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDetailCard({
    required String title,
    required List<Color> gradient,
    required IconData icon,
    String? category,
    String? label,
    String? note,
  }) {
    return ColorfulCard(
      gradient: gradient,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppFonts.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (label != null && label.trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.marginS),
              Text(
                label,
                style: AppFonts.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (category != null && category.trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.marginXS),
              _buildPill(category),
            ],
            if (note != null && note.trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.marginS),
              Text(
                note,
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppFonts.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await SoundService.instance.playClickSound();
          HapticFeedback.lightImpact();
          if (widget.onContinue != null) {
            widget.onContinue!();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusL),
          ),
          elevation: 4,
        ),
        child: Text(
          'Kembali ke Beranda',
          style: AppFonts.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
