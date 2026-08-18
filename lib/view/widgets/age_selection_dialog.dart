import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../providers/user_provider.dart';
import 'colorful_card.dart';

/// Dialog pilihan kategori usia (Di Bawah 13 Tahun vs 13+ Tahun)
class AgeSelectionDialog extends StatefulWidget {
  final Function(String category) onCategorySelected;
  final bool isDismissible;

  const AgeSelectionDialog({
    super.key,
    required this.onCategorySelected,
    this.isDismissible = true,
  });

  @override
  State<AgeSelectionDialog> createState() => _AgeSelectionDialogState();
}

class _AgeSelectionDialogState extends State<AgeSelectionDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleSelectCategory(String category) async {
    await SoundService.instance.playClickSound();
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedCategory = category;
    });

    final userProvider = context.read<UserProvider>();
    userProvider.setSelectedAgeCategory(category);

    if (mounted) {
      Navigator.of(context).pop();
      widget.onCategorySelected(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isDismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _bounceAnimation,
            child: ColorfulCard(
              gradient: const [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ),
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Header
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2),
                      tween: Tween(begin: 1.0, end: 1.15),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cake_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.marginM),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ).createShader(bounds),
                      child: Text(
                        'Pilih Kategori Usia',
                        style: AppFonts.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.marginS),

                    Text(
                      'Pilih kategori usia kamu untuk mendapatkan pertanyaan yang sesuai!',
                      style: AppFonts.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.marginL),

                    // Category Option 1: Under 13
                    _buildCategoryCard(
                      categoryKey: '<13',
                      title: 'Di Bawah 13 Tahun',
                      subtitle: 'Untuk anak-anak usia sekolah dasar (< 13 tahun)',
                      icon: Icons.child_care_rounded,
                      gradient: const [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                    ),

                    const SizedBox(height: AppDimensions.marginM),

                    // Category Option 2: 13+ Years
                    _buildCategoryCard(
                      categoryKey: '>=13',
                      title: '13 Tahun Ke Atas',
                      subtitle: 'Kuesioner Assesmen REI usia 13+ tahun (Remaja & Dewasa)',
                      icon: Icons.face_rounded,
                      gradient: const [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
                    ),

                    if (widget.isDismissible) ...[
                      const SizedBox(height: AppDimensions.marginM),
                      TextButton(
                        onPressed: () async {
                          await SoundService.instance.playClickSound();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Batal',
                          style: AppFonts.labelMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String categoryKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
  }) {
    final isSelected = _selectedCategory == categoryKey;

    return GestureDetector(
      onTap: () => _handleSelectCategory(categoryKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.radiusL),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.white.withOpacity(0.4),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppFonts.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
