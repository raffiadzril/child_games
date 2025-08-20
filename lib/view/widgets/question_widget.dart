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
  // Tap bounce animations per option (for image/emoticon)
  final Map<String, AnimationController> _tapControllers = {};
  final Map<String, Animation<double>> _tapScales = {};
  final Map<String, Animation<double>> _tapTilts = {};

  // For popup overlay
  bool _isShowingPopup = false;

  @override
  void initState() {
    super.initState();

    _optionsController = AnimationController(
      duration: Duration(milliseconds: 800 + (widget.options.length * 100)),
      vsync: this,
    );

    _initializeOptionAnimations();
    _optionsController.forward();

    // Initialize tap animations for current options
    _initializeTapAnimations(widget.options);
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

  void _initializeTapAnimations(List<OptionModel> options) {
    // Dispose controllers that are no longer used
    final existingKeys = _tapControllers.keys.toSet();
    final newKeys = options.map((o) => o.id).toSet();
    for (final key in existingKeys.difference(newKeys)) {
      _tapControllers[key]?.dispose();
      _tapControllers.remove(key);
      _tapScales.remove(key);
      _tapTilts.remove(key);
    }

    // Create controllers for new options
    for (final option in options) {
      if (_tapControllers.containsKey(option.id)) continue;
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 300),
      );
      final scale = Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
      // slight tilt to make it more lively
      final tilt = Tween<double>(
        begin: 0.0,
        end: 0.12,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
      _tapControllers[option.id] = controller;
      _tapScales[option.id] = scale;
      _tapTilts[option.id] = tilt;
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

    // Ensure tap animations map stays in sync with options list
    _initializeTapAnimations(widget.options);
  }

  @override
  void dispose() {
    // Dispose tap controllers
    for (final c in _tapControllers.values) {
      c.dispose();
    }
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
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
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
              child: Builder(
                builder: (context) {
                  final hasText = option.optionText != null;
                  final hasImage = option.imageUrl != null;

                  Widget buildImage() {
                    Widget img = ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radiusS),
                      child: Image.network(
                        option.imageUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(
                                AppRadius.radiusS,
                              ),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(
                                AppRadius.radiusS,
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Icon(
                              Icons.broken_image,
                              size: 28,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    );

                    // Simple bounce animation for the original image with Hero
                    return ScaleTransition(
                      scale:
                          _tapScales[option.id] ??
                          const AlwaysStoppedAnimation<double>(1.0),
                      child: Hero(
                        tag: 'popup-image-${option.imageUrl!}',
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppRadius.radiusS,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppRadius.radiusS,
                              ),
                            ),
                            child: img,
                          ),
                        ),
                      ),
                    );
                  }

                  if (hasText && hasImage) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildImage(),
                        const SizedBox(width: AppDimensions.marginM),
                        Expanded(
                          child: Text(
                            option.optionText!,
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (hasText) {
                    return Text(
                      option.optionText!,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    );
                  } else if (hasImage) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: buildImage(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
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

    // Trigger bounce animation on tapped option (if image exists)
    _triggerBounce(optionId);

    setState(() {
      _selectedOptionId = optionId;
    });
  }

  void _triggerBounce(String optionId) async {
    final controller = _tapControllers[optionId];
    if (controller == null) return;

    try {
      // Start small bounce animation first
      controller.forward(from: 0.0);

      // Small delay then show popup with Hero transition
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      _showImagePopup(optionId);

      // Keep popup visible for viewing
      await Future.delayed(const Duration(milliseconds: 2000));
    } catch (_) {
      // ignore animation errors if disposed mid-flight
    } finally {
      // Hide popup and reverse bounce
      _hideImagePopup();
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.reverse();
      }
    }
  }

  void _showImagePopup(String optionId) {
    if (_isShowingPopup) return;

    final option = widget.options.firstWhere((opt) => opt.id == optionId);
    if (option.imageUrl == null) return;

    _isShowingPopup = true;

    // Use Navigator for smooth Hero transition
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            opaque: false, // Allows background to show through
            barrierDismissible: true,
            pageBuilder: (context, animation, secondaryAnimation) {
              return _buildPopupPage(option.imageUrl!);
            },
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),
            reverseTransitionDuration: const Duration(milliseconds: 600),
          ),
        )
        .then((_) {
          // Reset popup state when navigation completes
          _isShowingPopup = false;
        });
  }

  void _hideImagePopup() {
    if (!_isShowingPopup) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    _isShowingPopup = false;
  }

  Widget _buildPopupPage(String imageUrl) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: _hideImagePopup, // Tap to close popup
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.7), // Semi-transparent background
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping the image
              child: Hero(
                tag: 'popup-image-$imageUrl',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 8,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radiusL),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.transparent,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.backgroundSecondary,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.backgroundSecondary,
                              child: Icon(
                                Icons.broken_image,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
