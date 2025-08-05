import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../widgets/challenges_grid.dart';

/// Home screen dengan challenge cards
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Child Games'),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: const ChallengesGrid(),
    );
  }
}
