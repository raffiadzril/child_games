import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/fonts.dart';
import '../../core/constants/radius.dart';
import '../../data/models/challenge_model.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/user_provider.dart';
import '../screens/quiz_screen.dart';
import 'challenges_card.dart';
import 'biodata_dialog.dart';
import 'age_selection_dialog.dart';

/// Widget grid untuk menampilkan challenges dengan Provider dan Filter Kategori Usia
class ChallengesGrid extends StatefulWidget {
  const ChallengesGrid({super.key});

  @override
  State<ChallengesGrid> createState() => _ChallengesGridState();
}

class _ChallengesGridState extends State<ChallengesGrid> {
  String _activeFilterCategory = 'all'; // 'all', '<13', '>=13'

  @override
  void initState() {
    super.initState();
    print('ChallengesGrid: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('ChallengesGrid: About to call loadChallenges');
      try {
        final provider = context.read<ChallengeProvider>();
        print('ChallengesGrid: Provider found successfully');
        provider.loadChallenges();

        final userProvider = context.read<UserProvider>();
        if (userProvider.selectedAgeCategory != null) {
          setState(() {
            _activeFilterCategory = userProvider.selectedAgeCategory!;
          });
        }
      } catch (e) {
        print('ChallengesGrid: Error accessing provider: $e');
      }
    });
  }

  List<ChallengeModel> _getFilteredChallenges(List<ChallengeModel> allChallenges) {
    if (_activeFilterCategory == 'all') {
      return allChallenges;
    }
    if (_activeFilterCategory == '<13') {
      return allChallenges
          .where((c) => c.category != 'REI 13+' && !c.title.contains('13+'))
          .toList();
    }
    if (_activeFilterCategory == '>=13') {
      return allChallenges
          .where((c) => c.category == 'REI 13+' || c.title.contains('13+'))
          .toList();
    }
    return allChallenges;
  }

  @override
  Widget build(BuildContext context) {
    print('ChallengesGrid: build called');
    return Consumer2<ChallengeProvider, UserProvider>(
      builder: (context, challengeProvider, userProvider, child) {
        print(
          'ChallengesGrid: Consumer builder called - loading: ${challengeProvider.isLoading}, error: ${challengeProvider.hasError}',
        );

        // Sync filter with userProvider if set
        if (userProvider.selectedAgeCategory != null &&
            _activeFilterCategory == 'all') {
          _activeFilterCategory = userProvider.selectedAgeCategory!;
        }

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
                Text(
                  challengeProvider.errorMessage ?? 'Terjadi kesalahan',
                  style: const TextStyle(color: Colors.white),
                ),
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
          return const Center(
            child: Text(
              'Tidak ada challenge tersedia',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final filteredChallenges = _getFilteredChallenges(challengeProvider.challenges);

        return Column(
          children: [
            // Filter Bar Kategori Usia
            _buildAgeFilterBar(userProvider),

            const SizedBox(height: AppDimensions.marginS),

            // Challenges List
            Expanded(
              child: filteredChallenges.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.white70,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada permainan untuk kategori usia ini',
                              style: AppFonts.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      child: ListView.builder(
                        itemCount: filteredChallenges.length,
                        itemBuilder: (context, index) {
                          final challenge = filteredChallenges[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.marginM,
                            ),
                            child: ChallengesCard(
                              title: challenge.title,
                              description: challenge.description,
                              imageUrl: challenge.imageUrl,
                              index: index,
                              onTap: () => _onChallengeSelected(challenge),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgeFilterBar(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Semua Usia',
              icon: Icons.grid_view_rounded,
              categoryValue: 'all',
              isSelected: _activeFilterCategory == 'all',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Di Bawah 13 Tahun',
              icon: Icons.child_care_rounded,
              categoryValue: '<13',
              isSelected: _activeFilterCategory == '<13',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '13+ Tahun',
              icon: Icons.face_rounded,
              categoryValue: '>=13',
              isSelected: _activeFilterCategory == '>=13',
            ),
            const SizedBox(width: 8),
            // Button to open Age Selection Dialog
            GestureDetector(
              onTap: () => _showAgeSelectionDialog(null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.radiusM),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_note_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Pilih Usia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required String categoryValue,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilterCategory = categoryValue;
        });
        if (categoryValue != 'all') {
          context.read<UserProvider>().setSelectedAgeCategory(categoryValue);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.radiusM),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF6B73FF) : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6B73FF) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onChallengeSelected(ChallengeModel challenge) {
    final userProvider = context.read<UserProvider>();

    if (userProvider.isUserLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(challenge: challenge),
        ),
      );
    } else {
      if (userProvider.selectedAgeCategory == null) {
        _showAgeSelectionDialog(challenge);
      } else {
        _showBiodataDialog(challenge);
      }
    }
  }

  void _showAgeSelectionDialog(ChallengeModel? challenge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AgeSelectionDialog(
        onCategorySelected: (category) {
          setState(() {
            _activeFilterCategory = category;
          });
          if (challenge != null) {
            _showBiodataDialog(challenge);
          }
        },
      ),
    );
  }

  void _showBiodataDialog(ChallengeModel challenge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BiodataDialog(
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(challenge: challenge),
            ),
          );
        },
      ),
    );
  }
}
