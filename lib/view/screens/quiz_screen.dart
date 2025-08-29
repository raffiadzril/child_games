import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _buildAnimatedAppBar(),
      body: AnimatedGradientBackground(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            // Loading state
            if (quizProvider.isLoading) {
              return _buildLoadingState();
            }

            // Error state
            if (quizProvider.hasError) {
              return _buildErrorState(quizProvider);
            }

            // Quiz completed state
            if (quizProvider.isQuizCompleted) {
              return _buildQuizResult(quizProvider);
            }

            // Quiz active state
            return Column(
              children: [
                // Animated Progress bar
                _buildAnimatedProgressBar(quizProvider),

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
                              onAnswerSelected: (optionId) async {
                                if (mounted) {
                                  final userProvider =
                                      context.read<UserProvider>();
                                  await quizProvider.submitAnswer(
                                    optionId,
                                    userProvider: userProvider,
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
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar() {
    return AppBar(
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          widget.challenge.title,
          style: AppFonts.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFonts.semiBold,
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundPrimary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppRadius.radiusM),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
        onPressed: () => _navigateBack(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppDimensions.marginL),
          Text(
            'Memuat pertanyaan...',
            style: AppFonts.bodyLarge.copyWith(color: AppColors.textSecondary),
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

  Widget _buildAnimatedProgressBar(QuizProvider quizProvider) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppRadius.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
                    color: AppColors.textSecondary,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.gradientPrimary),
                  borderRadius: BorderRadius.circular(AppRadius.radiusM),
                ),
                child: Text(
                  'Skor: ${quizProvider.score}',
                  style: AppFonts.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: AppFonts.semiBold,
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
                  color: AppColors.backgroundPrimary,
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
                      gradient: LinearGradient(
                        colors: AppColors.gradientPrimary,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.radiusS),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
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
