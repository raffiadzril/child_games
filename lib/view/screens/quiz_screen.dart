import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../core/services/sound_service.dart';
import '../../data/models/challenge_model.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';
import '../widgets/question_widget.dart';
import '../widgets/animated_gradient_background.dart';
import '../widgets/rei_result_widget.dart';
import '../widgets/quiz_review_widget.dart';

/// Screen untuk menampilkan quiz dengan animasi dan transisi
class QuizScreen extends StatefulWidget {
  final ChallengeModel challenge;

  const QuizScreen({super.key, required this.challenge});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasLoadedReiResult = false;

  @override
  void initState() {
    super.initState();

    // Reset loading flag
    _hasLoadedReiResult = false;

    // Initialize animation controllers
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Initialize animations
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Stop music completely for quiz session
        SoundService.instance.stopBackgroundMusic();

        // Reset REI result untuk quiz baru
        context.read<UserProvider>().resetReiResult();
        context.read<QuizProvider>().loadQuiz(widget.challenge);
        _startAnimations();
      }
    });
  }

  void _startAnimations() {
    if (!mounted) return; // Safety check

    _fadeController.forward();
    _progressController.forward();
  }

  /// Handle navigation back with music restart
  Future<void> _navigateBack() async {
    // Restart music when leaving quiz
    await SoundService.instance.startBackgroundMusic();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Note: Volume restore is handled in _navigateBack() for smooth user experience
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdultMode = context.watch<UserProvider>().isAdultMode;
    final bgColor = isAdultMode ? const Color(0xFFF8FAFC) : AppColors.backgroundPrimary;

    final bodyWidget = Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        // Review mode state — tampilkan setelah soal terakhir dijawab
        // Cek ini PERTAMA agar tidak terblokir oleh isLoading
        if (quizProvider.isReviewMode) {
          return const QuizReviewWidget();
        }

        // Quiz completed state — juga dicek sebelum loading
        if (quizProvider.isQuizCompleted) {
          return _buildQuizResult(quizProvider);
        }

        // Loading state (hanya saat load soal pertama kali)
        if (quizProvider.isLoading) {
          return _buildLoadingState(isAdultMode);
        }

        // Error state
        if (quizProvider.hasError) {
          return _buildErrorState(quizProvider);
        }

        // Quiz active state
        return Column(
          children: [
            // Animated Progress bar
            _buildAnimatedProgressBar(quizProvider, isAdultMode),

            // Animated Question content dengan smooth transition + error handling
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                ) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
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
                    quizProvider.currentQuestion != null &&
                            quizProvider.currentOptions != null
                        ? QuestionWidget(
                          key: ValueKey(
                            '${quizProvider.currentQuestion!.id}_${quizProvider.currentQuestionIndex}',
                          ),
                          question: quizProvider.currentQuestion!,
                          options: quizProvider.currentOptions!,
                          isLastQuestion: quizProvider.isLastQuestion,
                          preSelectedOptionId: quizProvider
                              .getSelectedOptionForQuestion(
                                quizProvider.currentQuestion!.id,
                              ),
                          onAnswerSelected: (optionId) async {
                            if (mounted) {
                              await quizProvider.submitAnswer(
                                optionId,
                              );
                            }
                          },
                        )
                        : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAnimatedAppBar(isAdultMode),
      floatingActionButton: AppConfig.isDeveloperMode
          ? Consumer<QuizProvider>(
              builder: (context, quizProvider, child) {
                if (quizProvider.isQuizCompleted) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton.extended(
                  onPressed: () => _showDeveloperAutoFillDialog(quizProvider),
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.bug_report_rounded, size: 20),
                  label: const Text(
                    'DEV: Auto-Fill',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                );
              },
            )
          : null,
      body: isAdultMode
          ? Container(color: bgColor, child: bodyWidget)
          : AnimatedGradientBackground(child: bodyWidget),
    );
  }

  void _showDeveloperAutoFillDialog(QuizProvider quizProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.developer_mode_rounded,
                    color: Color(0xFFA5B4FC),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Developer Mode: Auto-Fill Quiz',
                    style: AppFonts.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih template jawaban instan untuk menyelesaikan quiz otomatis saat debugging:',
                style: AppFonts.bodySmall.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.star_rounded, color: Colors.amber),
                title: const Text(
                  'Serba Tinggi (Max Score)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Mengisi semua item dengan nilai tertinggi (5)',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  quizProvider.autoFillAllAnswers(
                    userProvider: context.read<UserProvider>(),
                    template: 'high',
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.horizontal_rule_rounded,
                  color: Colors.cyanAccent,
                ),
                title: const Text(
                  'Sedang / Netral (Mean Score)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Mengisi semua item dengan nilai sedang (3)',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  quizProvider.autoFillAllAnswers(
                    userProvider: context.read<UserProvider>(),
                    template: 'medium',
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.shuffle_rounded,
                  color: Colors.lightGreenAccent,
                ),
                title: const Text(
                  'Random / Acak',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Mengisi item secara acak',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  quizProvider.autoFillAllAnswers(
                    userProvider: context.read<UserProvider>(),
                    template: 'random',
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar(bool isAdultMode) {
    return AppBar(
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          widget.challenge.title,
          style: AppFonts.headlineMedium.copyWith(
            color: isAdultMode ? const Color(0xFF0F172A) : AppColors.textPrimary,
            fontWeight: AppFonts.semiBold,
          ),
        ),
      ),
      backgroundColor: isAdultMode ? Colors.white : AppColors.backgroundPrimary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAdultMode ? const Color(0xFFF1F5F9) : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppRadius.radiusM),
            border: isAdultMode ? Border.all(color: const Color(0xFFE2E8F0)) : null,
            boxShadow: isAdultMode
                ? null
                : [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: isAdultMode ? const Color(0xFF334155) : AppColors.textPrimary,
            size: 18,
          ),
        ),
        onPressed: () => _navigateBack(),
      ),
      actions: [
        if (AppConfig.isDeveloperMode)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: TextButton.icon(
                onPressed: () => _showDeveloperAutoFillDialog(context.read<QuizProvider>()),
                icon: const Icon(Icons.bug_report_rounded, color: Color(0xFF4F46E5), size: 16),
                label: const Text(
                  'DEV: Auto-Fill',
                  style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF2FF),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFF818CF8)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState(bool isAdultMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: BoxDecoration(
              color: isAdultMode ? Colors.white : AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppRadius.radiusXL),
              border: isAdultMode ? Border.all(color: const Color(0xFFE2E8F0)) : null,
              boxShadow: [
                BoxShadow(
                  color: isAdultMode ? const Color(0x0D000000) : AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isAdultMode ? const Color(0xFF4F46E5) : AppColors.primary,
              ),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppDimensions.marginL),
          Text(
            'Memuat pertanyaan...',
            style: AppFonts.bodyLarge.copyWith(
              color: isAdultMode ? const Color(0xFF475569) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(QuizProvider quizProvider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.paddingL),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.marginL),
            Text(
              'Oops! Terjadi Kesalahan',
              style: AppFonts.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppFonts.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginM),
            Text(
              quizProvider.errorMessage ?? 'Terjadi kesalahan saat memuat quiz',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginXL),
            ElevatedButton.icon(
              onPressed: () => quizProvider.loadQuiz(widget.challenge),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.radiusButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressBar(QuizProvider quizProvider, bool isAdultMode) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: isAdultMode ? Colors.white : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.radiusL),
        border: isAdultMode ? Border.all(color: const Color(0xFFE2E8F0)) : null,
        boxShadow: [
          BoxShadow(
            color: isAdultMode ? const Color(0x0A000000) : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Pertanyaan ${quizProvider.currentQuestion?.questionNumber ?? quizProvider.currentQuestionIndex + 1} dari ${quizProvider.totalQuestions}',
                  style: AppFonts.bodyMedium.copyWith(
                    color: isAdultMode ? const Color(0xFF475569) : AppColors.textSecondary,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginM),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isAdultMode ? const Color(0xFFE2E8F0) : AppColors.backgroundPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.radiusS),
                ),
              ),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Container(
                    height: 8,
                    width:
                        MediaQuery.of(context).size.width *
                        (quizProvider.progress * _progressAnimation.value),
                    decoration: BoxDecoration(
                      color: isAdultMode ? const Color(0xFF4F46E5) : null,
                      gradient: isAdultMode
                          ? null
                          : LinearGradient(colors: AppColors.gradientPrimary),
                      borderRadius: BorderRadius.circular(AppRadius.radiusS),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResult(QuizProvider quizProvider) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Load REI result hanya sekali saat quiz completed
        if (!_hasLoadedReiResult && userProvider.isUserLoggedIn) {
          _hasLoadedReiResult = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.loadReiResult();
            // Start music again when quiz is completed and showing result
            SoundService.instance.startBackgroundMusic();
          });
        }

        if (userProvider.isLoading && !userProvider.hasReiResult) {
          return SingleChildScrollView(child: _buildLoadingREI());
        }

        if (userProvider.reiResult != null) {
          // Tampilkan hasil REI dengan scroll
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: ReiResultWidget(
              reiResult: userProvider.reiResult!,
              onContinue: () {
                _navigateBack();
              },
            ),
          );
        } else {
          // Tetap loading sampai REI result siap, tidak ada fallback
          return SingleChildScrollView(child: _buildLoadingREI());
        }
      },
    );
  }

  Widget _buildLoadingREI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading icon
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 6.28, // 2π for full rotation
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppDimensions.marginL),

          Text(
            'Menghitung Hasil REI...',
            style: AppFonts.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppDimensions.marginM),

          Text(
            'Respect • Equity • Inclusion',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
