import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/rei_accumulate_model.dart';
import '../../providers/user_provider.dart';
import 'colorful_card.dart';

/// Widget untuk menampilkan hasil REI (Respect, Equity, Inclusion)
/// Mendukung Light Theme untuk Mode Dewasa (13+ Tahun)
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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
    final isAdultMode = context.watch<UserProvider>().isAdultMode;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          children: [
            // Header dengan animasi pulse
            _buildHeader(isAdultMode),

            // Banner Kode Hasil Unik untuk Mode 13+
            if (isAdultMode) ...[
              const SizedBox(height: AppDimensions.marginM),
              _buildUniqueCodeCard(isAdultMode),
            ],

            const SizedBox(height: AppDimensions.marginL),

            // Score cards
            _buildScoreCards(isAdultMode),

            const SizedBox(height: AppDimensions.marginL),

            // Progress bars
            _buildProgressBars(isAdultMode),

            const SizedBox(height: AppDimensions.marginL),

            // Summary
            _buildSummary(isAdultMode),

            const SizedBox(height: AppDimensions.marginXL),

            // Continue button
            _buildContinueButton(isAdultMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAdultMode) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Column(
            children: [
              // Trophy / Analytics icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isAdultMode
                      ? const Color(0xFFEEF2FF)
                      : AppColors.primary,
                  gradient: isAdultMode
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                  shape: BoxShape.circle,
                  border: isAdultMode
                      ? Border.all(color: const Color(0xFFC7D2FE), width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isAdultMode
                          ? const Color(0x1F4F46E5)
                          : AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.assessment_rounded,
                  size: 48,
                  color: isAdultMode ? const Color(0xFF4F46E5) : Colors.white,
                ),
              ),

              const SizedBox(height: AppDimensions.marginM),

              // Title
              if (isAdultMode)
                Text(
                  'Hasil Evaluasi REI 13+',
                  style: AppFonts.headlineLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                )
              else
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
                  color: isAdultMode
                      ? const Color(0xFF475569)
                      : AppColors.textSecondary,
                  fontWeight: isAdultMode ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreCards(bool isAdultMode) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: _buildScoreCard(
              'Respect',
              widget.reiResult.respect,
              isAdultMode ? const Color(0xFFFFF1F2) : null,
              isAdultMode ? const Color(0xFFFECDD3) : null,
              isAdultMode ? const Color(0xFFBE123C) : Colors.white,
              const [Color(0xFF6B73FF), Color(0xFF9BA3FF)],
              Icons.favorite_border_rounded,
              isAdultMode,
            ),
          ),
          const SizedBox(width: AppDimensions.marginM),
          Expanded(
            flex: 1,
            child: _buildScoreCard(
              'Equity',
              widget.reiResult.equity,
              isAdultMode ? const Color(0xFFEFF6FF) : null,
              isAdultMode ? const Color(0xFFBFDBFE) : null,
              isAdultMode ? const Color(0xFF1D4ED8) : Colors.white,
              const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              Icons.balance_rounded,
              isAdultMode,
            ),
          ),
          const SizedBox(width: AppDimensions.marginM),
          Expanded(
            flex: 1,
            child: _buildScoreCard(
              'Inclusion',
              widget.reiResult.inclusion,
              isAdultMode ? const Color(0xFFECFDF5) : null,
              isAdultMode ? const Color(0xFFA7F3D0) : null,
              isAdultMode ? const Color(0xFF047857) : Colors.white,
              const [Color(0xFFFF9F43), Color(0xFFFFD93D)],
              Icons.groups_outlined,
              isAdultMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(
    String title,
    int score,
    Color? bgColor,
    Color? borderColor,
    Color textColor,
    List<Color> gradient,
    IconData icon,
    bool isAdultMode,
  ) {
    final cardContent = Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: textColor),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              title,
              style: AppFonts.labelSmall.copyWith(
                color: textColor.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<int>(
            duration: const Duration(milliseconds: 1500),
            tween: IntTween(begin: 0, end: score),
            builder: (context, value, child) {
              return Text(
                value.toString(),
                style: AppFonts.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              );
            },
          ),
        ],
      ),
    );

    if (isAdultMode) {
      return Container(
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.radiusCard),
          border: Border.all(color: borderColor ?? const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: cardContent,
      );
    }

    return ColorfulCard(
      gradient: gradient,
      child: cardContent,
    );
  }

  Widget _buildProgressBars(bool isAdultMode) {
    final percentages = widget.reiResult.categoryPercentages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribusi Skor Dimensi',
          style: AppFonts.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: isAdultMode ? const Color(0xFF0F172A) : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.marginM),

        _buildProgressBar(
          'Respect',
          percentages['respect']! / 100,
          isAdultMode ? const Color(0xFFEC4899) : const Color(0xFF6B73FF),
          widget.reiResult.respect,
          isAdultMode,
        ),
        const SizedBox(height: AppDimensions.marginM),

        _buildProgressBar(
          'Equity',
          percentages['equity']! / 100,
          isAdultMode ? const Color(0xFF2563EB) : const Color(0xFF4ECDC4),
          widget.reiResult.equity,
          isAdultMode,
        ),
        const SizedBox(height: AppDimensions.marginM),

        _buildProgressBar(
          'Inclusion',
          percentages['inclusion']! / 100,
          isAdultMode ? const Color(0xFF059669) : const Color(0xFFFF9F43),
          widget.reiResult.inclusion,
          isAdultMode,
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    String label,
    double percentage,
    Color color,
    int score,
    bool isAdultMode,
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
                fontWeight: FontWeight.w600,
                color: isAdultMode ? const Color(0xFF0F172A) : AppColors.textPrimary,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}% ($score poin)',
              style: AppFonts.bodySmall.copyWith(
                color: isAdultMode ? const Color(0xFF475569) : AppColors.textSecondary,
                fontWeight: isAdultMode ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginXS),

        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isAdultMode ? const Color(0xFFE2E8F0) : AppColors.backgroundSecondary,
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(bool isAdultMode) {
    final r = widget.reiResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Overall summary card
        if (isAdultMode)
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(AppRadius.radiusL),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.marginS),
                Text(
                  'TOTAL SKOR EVALUASI\n${r.totalScore}',
                  style: AppFonts.displayMedium.copyWith(
                    color: const Color(0xFF1E1B4B),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if ((r.allCategory ?? r.labelAnakRamahCategory) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.marginM),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Kategori: ${(r.allCategory ?? r.labelAnakRamahCategory)!}',
                        style: AppFonts.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (r.allNote != null && r.allNote!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.marginM),
                    child: Text(
                      r.allNote!,
                      style: AppFonts.bodyMedium.copyWith(
                        color: const Color(0xFF3730A3),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          )
        else
          ColorfulCard(
            gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.marginS),
                  Text(
                    'SKOR REI\n${r.totalScore}',
                    style: AppFonts.displayMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
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
                icon: Icons.favorite_border_rounded,
                isAdultMode: isAdultMode,
              ),
              _buildCategoryDetailCard(
                title: 'Equity',
                gradient: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                category: r.equityCategory,
                note: r.equityNote,
                label: r.labelAnakRamahCategoryEquity,
                icon: Icons.balance_rounded,
                isAdultMode: isAdultMode,
              ),
              _buildCategoryDetailCard(
                title: 'Inclusion',
                gradient: const [Color(0xFFFF9F43), Color(0xFFFFD93D)],
                category: r.inclusionCategory,
                note: r.inclusionNote,
                label: r.labelAnakRamahCategoryInclusion,
                icon: Icons.groups_outlined,
                isAdultMode: isAdultMode,
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

            return IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 1, child: children[0]),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(flex: 1, child: children[1]),
                  const SizedBox(width: AppDimensions.marginM),
                  Expanded(flex: 1, child: children[2]),
                ],
              ),
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
    required bool isAdultMode,
    String? category,
    String? label,
    String? note,
  }) {
    final content = Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isAdultMode ? const Color(0xFF4F46E5) : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: AppFonts.bodySmall.copyWith(
                    color: isAdultMode ? const Color(0xFF0F172A) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (label != null && label.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              label,
              style: AppFonts.labelMedium.copyWith(
                color: isAdultMode ? const Color(0xFF334155) : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (category != null && category.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildPill(category, isAdultMode),
          ],
          if (note != null && note.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                note,
                style: AppFonts.bodySmall.copyWith(
                  color: isAdultMode
                      ? const Color(0xFF475569)
                      : Colors.white.withOpacity(0.95),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    if (isAdultMode) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.radiusCard),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: content,
      );
    }

    return ColorfulCard(
      gradient: gradient,
      child: content,
    );
  }

  Widget _buildPill(String text, bool isAdultMode) {
    Color bg = isAdultMode ? const Color(0xFFF1F5F9) : Colors.white.withOpacity(0.18);
    Color fg = isAdultMode ? const Color(0xFF334155) : Colors.white;
    Border? border = isAdultMode ? Border.all(color: const Color(0xFFCBD5E1)) : null;

    if (isAdultMode) {
      if (text == 'Tinggi') {
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        border = Border.all(color: const Color(0xFFA7F3D0));
      } else if (text == 'Sedang') {
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        border = Border.all(color: const Color(0xFFFDE68A));
      } else if (text == 'Rendah') {
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        border = Border.all(color: const Color(0xFFFECACA));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border,
      ),
      child: Text(
        text,
        style: AppFonts.labelMedium.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isAdultMode) {
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
          backgroundColor: isAdultMode ? const Color(0xFF4F46E5) : AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusL),
          ),
          elevation: 2,
        ),
        child: Text(
          'Kembali ke Menu Utama',
          style: AppFonts.gameButton.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUniqueCodeCard(bool isAdultMode) {
    // Generate code on the fly if model uniqueCode is empty
    String displayCode = widget.reiResult.uniqueCode ?? '';
    if (displayCode.isEmpty) {
      final rPct = ((widget.reiResult.respect / 15.0) * 20.0).clamp(0.0, 100.0);
      final ePct = ((widget.reiResult.equity / 15.0) * 20.0).clamp(0.0, 100.0);
      final iPct = ((widget.reiResult.inclusion / 15.0) * 20.0).clamp(0.0, 100.0);
      final oPct = (((rPct + ePct + iPct) / 3.0)).clamp(0.0, 100.0);
      final codeId = (widget.reiResult.id.hashCode & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0');
      displayCode = 'REI13-${rPct.toStringAsFixed(1)}-${ePct.toStringAsFixed(1)}-${iPct.toStringAsFixed(1)}-${oPct.toStringAsFixed(1)}-$codeId';
    }

    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.marginS),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isAdultMode ? const Color(0xFFEEF2FF) : Colors.amber.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.radiusCard),
        border: Border.all(
          color: isAdultMode ? const Color(0xFF6366F1) : Colors.amber,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.vpn_key_rounded,
                color: isAdultMode ? const Color(0xFF4F46E5) : Colors.amber,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kode Unik Hasil Asesmen REI (13+)',
                  style: AppFonts.headlineSmall.copyWith(
                    color: isAdultMode ? const Color(0xFF1E1B4B) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Salin kode di bawah dan masukkan ke Athlete Dashboard untuk mengklaim hasil tes Anda:',
            style: AppFonts.bodySmall.copyWith(
              color: isAdultMode ? const Color(0xFF4338CA) : Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isAdultMode ? Colors.white : Colors.black45,
              borderRadius: BorderRadius.circular(AppRadius.radiusM),
              border: Border.all(
                color: isAdultMode ? const Color(0xFFC7D2FE) : Colors.white24,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    displayCode,
                    style: AppFonts.bodyLarge.copyWith(
                      color: isAdultMode ? const Color(0xFF1E1B4B) : Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: displayCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Kode hasil REI berhasil disalin! Masukkan ke Athlete Dashboard.'),
                        backgroundColor: Color(0xFF059669),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Salin Kode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdultMode ? const Color(0xFF4F46E5) : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
