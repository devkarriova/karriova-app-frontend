import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/routes/app_router.dart';
import 'package:karriova_app/core/widgets/header/app_header.dart';
import 'package:karriova_app/core/widgets/navigation/app_navigation_bar.dart';
import 'package:karriova_app/features/assessment/pages/enhanced_career_blueprint_page.dart';
import 'package:karriova_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:karriova_app/features/auth/presentation/bloc/auth_state.dart';

class CareerRoadmapPage extends StatelessWidget {
  const CareerRoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final hasCompletedKit = authState.assessmentCompleted == true;
        return hasCompletedKit
            ? _buildReadyState(context)
            : _buildTakeKitPrompt(context);
      },
    );
  }

  Widget _buildReadyState(BuildContext context) {
    // Show in the same shell pattern as Events page
    return const Scaffold(
      appBar: AppHeader(),
      body: Column(
        children: [
          AppNavigationBar(currentRoute: AppRouter.careerRoadmap),
          Expanded(
            child: EnhancedCareerBlueprintPage(embedded: true),
          ),
        ],
      ),
    );

  }

  Widget _buildTakeKitPrompt(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          const AppNavigationBar(currentRoute: AppRouter.careerRoadmap),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.psychology_outlined,
                        color: AppColors.primary,
                        size: 52,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Complete KIT to Unlock Your Career Roadmap',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your career blueprints are generated from your KIT assessment results.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context.go(AppRouter.assessment),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Take Assessment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
