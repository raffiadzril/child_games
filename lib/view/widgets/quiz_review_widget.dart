import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/option_model.dart';
import '../../data/models/question_model.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';

/// Widget review screen yang ditampilkan setelah soal terakhir
/// Menampilkan daftar semua soal & jawaban, serta soal yang belum terisi
class QuizReviewWidget extends StatefulWidget {
  const QuizReviewWidget({super.key});

  @override
  State<QuizReviewWidget> createState() => _QuizReviewWidgetState();
}

class _QuizReviewWidgetState extends State<QuizReviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdultMode = context.watch<UserProvider>().isAdultMode;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, _) {
          final answeredCount =
              quizProvider.questionsWithOptions.length -
              quizProvider.unansweredQuestionIndices.length;
          final totalCount = quizProvider.questionsWithOptions.length;
          final allAnswered = quizProvider.allAnswered;

          return Column(
            children: [
              // Header summary
              _buildHeader(
                isAdultMode,
                answeredCount,
                totalCount,
                allAnswered,
              ),

              // List soal
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  itemCount: quizProvider.questionsWithOptions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionItem(
                      context,
                      quizProvider,
                      index,
                      isAdultMode,
                    );
                  },
                ),
              ),

              // Footer dengan tombol submit
              _buildFooter(context, quizProvider, isAdultMode, allAnswered),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    bool isAdultMode,
    int answered,
    int total,
    bool allAnswered,
  ) {
    final bgColor = isAdultMode ? Colors.white : AppColors.backgroundSecondary;
    final borderColor =
        isAdultMode ? const Color(0xFFE2E8F0) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusL),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isAdultMode
                ? const Color(0x0A000000)
                : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: allAnswered
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.radiusM),
                ),
                child: Icon(
                  allAnswered
                      ? Icons.check_circle_rounded
                      : Icons.warning_rounded,
                  color: allAnswered
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimensions.marginM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periksa Jawaban',
                      style: AppFonts.titleMedium.copyWith(
                        color: isAdultMode
                            ? const Color(0xFF0F172A)
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      allAnswered
                          ? 'Semua soal sudah terjawab! Siap dikirim.'
                          : 'Masih ada soal yang belum dijawab.',
                      style: AppFonts.bodySmall.copyWith(
                        color: isAdultMode
                            ? const Color(0xFF64748B)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginM),
          // Progress bar ringkasan
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppRadius.radiusS),
                  child: LinearProgressIndicator(
                    value: total > 0 ? answered / total : 0,
                    backgroundColor: isAdultMode
                        ? const Color(0xFFE2E8F0)
                        : AppColors.backgroundPrimary,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      allAnswered
                          ? const Color(0xFF10B981)
                          : const Color(0xFF4F46E5),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.marginM),
              Text(
                '$answered/$total',
                style: AppFonts.labelMedium.copyWith(
                  color: isAdultMode
                      ? const Color(0xFF334155)
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(
    BuildContext context,
    QuizProvider quizProvider,
    int index,
    bool isAdultMode,
  ) {
    final qMap = quizProvider.questionsWithOptions[index];
    final question = qMap['question'] as QuestionModel;
    final options = qMap['options'] as List<OptionModel>;
    final selectedOptionId = quizProvider.answersMap[question.id];
    final isAnswered = selectedOptionId != null;
    final isUnanswered = !isAnswered;

    OptionModel? selectedOption;
    if (selectedOptionId != null) {
      try {
        selectedOption = options.firstWhere((o) => o.id == selectedOptionId);
      } catch (_) {}
    }

    final cardBg = isUnanswered
        ? const Color(0xFFFFF3C7)
        : (isAdultMode ? Colors.white : AppColors.backgroundSecondary);

    final borderColor = isUnanswered
        ? const Color(0xFFF59E0B)
        : (isAdultMode ? const Color(0xFFE2E8F0) : AppColors.border);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: AppDimensions.marginM),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radiusCard),
        border: Border.all(
          color: borderColor,
          width: isUnanswered ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAdultMode
                ? const Color(0x08000000)
                : AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nomor soal
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isUnanswered
                    ? const Color(0xFFF59E0B)
                    : (isAdultMode
                        ? const Color(0xFF4F46E5)
                        : AppColors.primary),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${question.questionNumber}',
                  style: AppFonts.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.marginM),

            // Konten soal & jawaban
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teks soal (dipotong jika terlalu panjang)
                  Text(
                    question.questionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.bodySmall.copyWith(
                      color: isAdultMode
                          ? const Color(0xFF334155)
                          : AppColors.textPrimary,
                      fontWeight: isAdultMode ? FontWeight.w600 : FontWeight.w500,
                      fontSize: isAdultMode ? 15.0 : 13.0,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Jawaban yang dipilih atau badge "Belum dijawab"
                  if (isAnswered && selectedOption != null)
                    _buildAnswerBadge(selectedOption, isAdultMode)
                  else
                    _buildUnansweredBadge(isAdultMode),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.marginS),

            // Tombol Edit
            TextButton.icon(
              onPressed: () => _jumpToQuestion(context, quizProvider, index),
              icon: Icon(
                Icons.edit_rounded,
                size: 14,
                color: isAdultMode
                    ? const Color(0xFF4F46E5)
                    : AppColors.primary,
              ),
              label: Text(
                'Edit',
                style: AppFonts.labelSmall.copyWith(
                  color: isAdultMode
                      ? const Color(0xFF4F46E5)
                      : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerBadge(OptionModel option, bool isAdultMode) {
    final label = option.optionLabel != null ? '${option.optionLabel}. ' : '';
    final text = option.optionText ?? '';
    final hasImage = option.imageUrl != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdultMode
            ? const Color(0xFFEEF2FF)
            : AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: isAdultMode ? const Color(0xFF4F46E5) : AppColors.primary,
          ),
          const SizedBox(width: 4),
          if (hasImage)
            Text(
              '${label}[Gambar]',
              style: AppFonts.labelSmall.copyWith(
                color: isAdultMode
                    ? const Color(0xFF4F46E5)
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Flexible(
              child: Text(
                          '$label$text',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.labelSmall.copyWith(
                  color: isAdultMode
                      ? const Color(0xFF4F46E5)
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnansweredBadge(bool isAdultMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(AppRadius.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.radio_button_unchecked_rounded,
            size: 14,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 4),
          Text(
            'Belum dijawab',
            style: AppFonts.labelSmall.copyWith(
              color: const Color(0xFFD97706),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    QuizProvider quizProvider,
    bool isAdultMode,
    bool allAnswered,
  ) {
    final unansweredCount = quizProvider.unansweredQuestionIndices.length;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingL,
        AppDimensions.paddingM,
        AppDimensions.paddingL,
        AppDimensions.paddingL + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isAdultMode ? Colors.white : AppColors.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: isAdultMode
                ? const Color(0xFFE2E8F0)
                : AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isAdultMode
                ? const Color(0x10000000)
                : AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Peringatan jika masih ada yang belum dijawab
          if (!allAnswered) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppRadius.radiusM),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$unansweredCount soal belum dijawab. Harap jawab semua soal sebelum mengirim.',
                      style: AppFonts.bodySmall.copyWith(
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.marginM),
          ],

          // Tombol kirim
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSubmitting
                  ? Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: isAdultMode
                            ? const Color(0xFF4F46E5)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          AppRadius.radiusButton,
                        ),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      key: ValueKey(allAnswered),
                      onPressed: allAnswered
                          ? () => _submitFinal(context, quizProvider)
                          : null,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      label: Text(
                        allAnswered
                            ? 'Kirim Jawaban'
                            : 'Jawab Semua Soal Dulu',
                        style: AppFonts.gameButton.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: allAnswered
                            ? (isAdultMode
                                ? const Color(0xFF4F46E5)
                                : AppColors.primary)
                            : (isAdultMode
                                ? const Color(0xFFCBD5E1)
                                : AppColors.border),
                        disabledBackgroundColor: isAdultMode
                            ? const Color(0xFFCBD5E1)
                            : AppColors.border,
                        disabledForegroundColor: isAdultMode
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadius.radiusButton,
                          ),
                        ),
                        elevation: allAnswered ? 2 : 0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _jumpToQuestion(
    BuildContext context,
    QuizProvider quizProvider,
    int questionIndex,
  ) async {
    await SoundService.instance.playClickSound();
    HapticFeedback.lightImpact();
    quizProvider.jumpToQuestion(questionIndex);
  }

  Future<void> _submitFinal(
    BuildContext context,
    QuizProvider quizProvider,
  ) async {
    if (_isSubmitting) return;
    await SoundService.instance.playClickSound();
    HapticFeedback.mediumImpact();

    setState(() => _isSubmitting = true);

    final userProvider = context.read<UserProvider>();
    await quizProvider.submitFinalAnswers(userProvider: userProvider);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }
}
