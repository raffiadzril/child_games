import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/question_model.dart';
import '../../data/models/option_model.dart';
import 'question_media_widget.dart';

/// Widget untuk menampilkan pertanyaan dan opsi jawaban
class QuestionWidget extends StatefulWidget {
  final QuestionModel question;
  final List<OptionModel> options;
  final Function(String) onAnswerSelected;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.options,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget>
    with TickerProviderStateMixin {
  String? _selectedOptionId;
  late AnimationController _optionsController;
  late List<Animation<double>> _optionAnimations;

  @override
  void initState() {
    super.initState();

    _optionsController = AnimationController(
      duration: Duration(milliseconds: 800 + (widget.options.length * 100)),
      vsync: this,
    );

    _initializeOptionAnimations();
    _optionsController.forward();
  }

  void _initializeOptionAnimations() {
    _optionAnimations = [];

    // Safety check untuk mencegah error jika widget sudah disposed
    if (!mounted) return;

    for (int i = 0; i < widget.options.length; i++) {
      final start = i * 0.1;
      final end = (start + 0.3).clamp(
        0.0,
        1.0,
      ); // Clamp untuk memastikan nilai valid

      _optionAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _optionsController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(QuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset state when question changes
    if (oldWidget.question.id != widget.question.id) {
      _selectedOptionId = null;

      // Hanya reinitialize jika jumlah options berbeda
      if (oldWidget.options.length != widget.options.length) {
        if (mounted) {
          _optionsController.stop();
          _initializeOptionAnimations();

          // Start animation for new question
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _optionsController.forward(from: 0.0);
            }
          });
        }
      } else {
        // Jika jumlah options sama, langsung show semua options tanpa animasi
        if (mounted) {
          _optionsController.value = 1.0;
        }
      }
    }
  }

  @override
  void dispose() {
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question media (image/video if exists)
          if (widget.question.hasMedia) ...[
            Center(
              child: QuestionMediaWidget(
                question: widget.question,
                height: 200,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),
          ],

          // Question text
          Text(
            widget.question.questionText,
            style: AppFonts.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginL),

          // Options dengan conditional animation - menggunakan Column agar semua terlihat
          ...widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;

            // Safety check untuk animasi
            if (index >= _optionAnimations.length) {
              return _buildOptionCard(option);
            }

            return AnimatedBuilder(
              animation: _optionAnimations[index],
              builder: (context, child) {
                // Jika animasi sudah complete, render langsung tanpa transform
                if (_optionsController.isCompleted) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.marginM,
                    ),
                    child: _buildOptionCard(option),
                  );
                }

                // Safety check untuk nilai animasi
                final animationValue = _optionAnimations[index].value.clamp(
                  0.0,
                  1.0,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.marginM),
                  child: Transform.translate(
                    offset: Offset(
                      (1 - animationValue) *
                          50, // Reduced distance for smoother effect
                      0,
                    ),
                    child: Opacity(
                      opacity: animationValue,
                      child: _buildOptionCard(option),
                    ),
                  ),
                );
              },
            );
          }).toList(),

          // Next button dengan smooth animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child:
                _selectedOptionId != null
                    ? Column(
                      key: const ValueKey('next-button'),
                      children: [
                        const SizedBox(height: AppDimensions.marginL),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingM,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radiusButton,
                                ),
                              ),
                            ),
                            child: Text(
                              'Lanjutkan',
                              style: AppFonts.gameButton.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(OptionModel option) {
    final isSelected = _selectedOptionId == option.id;

    return InkWell(
      onTap: () => _selectOption(option.id),
      borderRadius: BorderRadius.circular(AppRadius.radiusCard),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.backgroundSecondary,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.radiusCard),
        ),
        child: Row(
          children: [
            // Option label (A, B, C, D) dengan smooth transition
            if (option.optionLabel != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary
                          : AppColors.backgroundPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    option.optionLabel!,
                    style: AppFonts.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: AppFonts.semiBold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.marginM),
            ],

            // Option content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Option text
                  if (option.optionText != null) ...[
                    Text(
                      option.optionText!,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],

                  // Option image
                  if (option.imageUrl != null) ...[
                    const SizedBox(height: AppDimensions.marginS),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.radiusS),
                        child: Image.network(
                          option.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radiusS,
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radiusS,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gambar tidak dapat dimuat',
                                    style: AppFonts.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectOption(String optionId) async {
    if (!mounted) return; // Safety check

    // Play click sound effect dan haptic feedback
    await SoundService.instance.playClickSound();
    HapticFeedback.lightImpact();

    setState(() {
      _selectedOptionId = optionId;
    });
  }

  void _handleSubmit() async {
    if (_selectedOptionId == null || !mounted) return;

    // Play click sound effect dan haptic feedback
    await SoundService.instance.playClickSound();
    HapticFeedback.mediumImpact();

    // Langsung proceed ke pertanyaan berikutnya
    widget.onAnswerSelected(_selectedOptionId!);
  }
}
