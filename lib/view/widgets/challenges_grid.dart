import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dimensions.dart';
import '../../providers/challenge_provider.dart';
import '../screens/quiz_screen.dart';
import 'challenges_card.dart';

/// Widget grid untuk menampilkan challenges dengan Provider
class ChallengesGrid extends StatefulWidget {
  const ChallengesGrid({super.key});

  @override
  State<ChallengesGrid> createState() => _ChallengesGridState();
}

class _ChallengesGridState extends State<ChallengesGrid> {
  @override
  void initState() {
    super.initState();
    print('ChallengesGrid: initState called');
    // Panggil provider untuk load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('ChallengesGrid: About to call loadChallenges');
      try {
        final provider = context.read<ChallengeProvider>();
        print('ChallengesGrid: Provider found successfully');
        provider.loadChallenges();
      } catch (e) {
        print('ChallengesGrid: Error accessing provider: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('ChallengesGrid: build called');
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, child) {
        print(
          'ChallengesGrid: Consumer builder called - loading: ${challengeProvider.isLoading}, error: ${challengeProvider.hasError}',
        );
        // Loading state
        if (challengeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (challengeProvider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(challengeProvider.errorMessage ?? 'Terjadi kesalahan'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => challengeProvider.loadChallenges(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (challengeProvider.challenges.isEmpty) {
          return const Center(child: Text('Tidak ada challenge tersedia'));
        }

        // Success state - show grid
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.marginM,
              mainAxisSpacing: AppDimensions.marginM,
              childAspectRatio: 0.8,
            ),
            itemCount: challengeProvider.challenges.length,
            itemBuilder: (context, index) {
              final challenge = challengeProvider.challenges[index];
              return ChallengesCard(
                title: challenge.title,
                description: challenge.description,
                imageUrl: challenge.imageUrl,
                onTap: () => _onChallengeSelected(challenge),
              );
            },
          ),
        );
      },
    );
  }

  void _onChallengeSelected(challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(challenge: challenge)),
    );
  }
}
