import 'package:child_games/core/constants/fonts.dart';
import 'package:child_games/core/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/radius.dart';
import 'colorful_card.dart';
import '../../core/constants/colors.dart';

/// Widget card untuk menampilkan challenge dengan design colorful
class ChallengesCard extends StatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final VoidCallback? onTap;
  final int index; // untuk variasi warna

  const ChallengesCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.onTap,
    this.index = 0,
  });

  @override
  State<ChallengesCard> createState() => _ChallengesCardState();
}

class _ChallengesCardState extends State<ChallengesCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Array gradients untuk variasi warna berdasarkan index
  static const List<List<Color>> cardGradients = [
    [Color(0xFF6B73FF), Color(0xFF9BA3FF)], // Purple
    [Color(0xFFFF6B9D), Color(0xFFFFB3D1)], // Pink
    [Color(0xFFFF9F43), Color(0xFFFFD93D)], // Orange-Yellow
    [Color(0xFF6BCF7F), Color(0xFF4ECDC4)], // Green-Turquoise
    [Color(0xFFFF6B6B), Color(0xFFFFD93D)], // Red-Yellow
    [Color(0xFF4ECDC4), Color(0xFF6B73FF)], // Turquoise-Purple
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = cardGradients[widget.index % cardGradients.length];

    return ColorfulCard(
      gradient: gradient,
      onTap: () async {
        // Play sound effect dan haptic feedback
        await SoundService.instance.playClickSound();
        HapticFeedback.lightImpact();

        // Execute original onTap
        if (widget.onTap != null) widget.onTap!();
      },
      child: IntrinsicHeight(
        child: Column(
          children: [
            // Challenge Image dengan animasi pulse - di tengah dengan dynamic height
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppDimensions.paddingS),
              constraints: const BoxConstraints(minHeight: 100, maxHeight: 180),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radiusM),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child:
                            widget.imageUrl != null
                                ? Image.network(
                                  widget.imageUrl!,
                                  fit:
                                      BoxFit
                                          .contain, // Changed to contain for better visibility
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 140,
                                      child: _buildPlaceholderImage(),
                                    );
                                  },
                                )
                                : Container(
                                  height: 140,
                                  child: _buildPlaceholderImage(),
                                ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Challenge Content - di bawah gambar dengan dynamic height
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title dengan gradient text - center aligned
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [AppColors.accent2, Colors.white70],
                        ).createShader(bounds),
                    child: Text(
                      widget.title,
                      style: AppFonts.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginXS),

                  // Description - center aligned
                  Text(
                    widget.description,
                    style: AppFonts.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10.0, // Set to 10px
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.marginM),

                  // Play button dengan animasi - centered
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (value * 0.2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Main',
                                style: AppFonts.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingS),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.games, size: 48, color: Colors.white.withOpacity(0.7)),
          const SizedBox(height: 8),
          Text(
            'Game Challenge',
            style: AppFonts.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
