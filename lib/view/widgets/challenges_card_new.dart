import 'package:child_games/core/constants/fonts.dart';
import 'package:child_games/core/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/radius.dart';
import 'colorful_card.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge Image dengan animasi pulse
          Expanded(
            flex: 2,
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
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderImage();
                                },
                              )
                              : _buildPlaceholderImage(),
                    ),
                  ),
                );
              },
            ),
          ),

          // Challenge Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title dengan gradient text
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [Colors.white, Colors.white70],
                        ).createShader(bounds),
                    child: Text(
                      widget.title,
                      style: AppFonts.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginXS),

                  // Description
                  Expanded(
                    child: Text(
                      widget.description,
                      style: AppFonts.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.marginXS),

                  // Play button dengan animasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (value * 0.2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
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
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Main',
                                    style: AppFonts.labelSmall.copyWith(
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
