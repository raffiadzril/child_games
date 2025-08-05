import 'package:child_games/core/constants/fonts.dart';
import 'package:child_games/core/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/radius.dart';

/// Widget card untuk menampilkan challenge
class ChallengesCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ChallengesCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusCard),
      ),
      child: InkWell(
        onTap: () async {
          // Play sound effect dan haptic feedback
          await SoundService.instance.playClickSound();
          HapticFeedback.lightImpact();

          // Execute original onTap
          if (onTap != null) onTap!();
        },
        borderRadius: BorderRadius.circular(AppRadius.radiusCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge Image
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.radiusCard),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundCard,
                  ),
                  child:
                      imageUrl != null
                          ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          )
                          : _buildPlaceholderImage(),
                ),
              ),
            ),

            // Challenge Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Challenge Title
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Action Button
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Play sound effect dan haptic feedback
                              await SoundService.instance.playClickSound();
                              HapticFeedback.mediumImpact();

                              // Execute original onTap
                              if (onTap != null) onTap!();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnDark,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingXS,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radiusButton,
                                ),
                              ),
                            ),
                            child: Text(
                              'Mulai',
                              style: TextStyle(
                                fontSize: AppFonts.fontSizeS,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientPrimary,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.emoji_events,
          size: AppDimensions.iconXXL,
          color: AppColors.textOnDark,
        ),
      ),
    );
  }
}
