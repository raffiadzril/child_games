import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/radius.dart';

/// Widget card untuk menampilkan game
class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String category;
  final String difficulty;
  final VoidCallback? onTap;
  final bool isActive;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.difficulty,
    this.onTap,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusGameCard),
      ),
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.radiusGameCard),
        child: Container(
          width: AppDimensions.gameCardWidth,
          height: AppDimensions.gameCardHeight,
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game Image
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.radiusImage),
                  color: AppColors.backgroundCard,
                ),
                child:
                    imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppRadius.radiusImage,
                          ),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          ),
                        )
                        : _buildPlaceholderImage(),
              ),

              const SizedBox(height: AppDimensions.marginS),

              // Game Title
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isActive ? AppColors.textPrimary : AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDimensions.marginXS),

              // Category and Difficulty
              Row(
                children: [
                  _buildChip(label: category, color: AppColors.accent2),
                  const SizedBox(width: AppDimensions.marginXS),
                  _buildChip(
                    label: difficulty,
                    color: _getDifficultyColor(difficulty),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.marginXS),

              // Description
              Expanded(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isActive
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radiusImage),
        gradient: const LinearGradient(
          colors: AppColors.gradientPrimary,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.games,
          size: AppDimensions.iconXL,
          color: AppColors.textOnDark,
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.radiusChip),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
