import 'package:flutter/material.dart';
import 'package:karriova_app/core/routes/app_router.dart';
import 'package:karriova_app/core/widgets/header/app_header.dart';
import 'package:karriova_app/core/widgets/navigation/app_navigation_bar.dart';
import 'package:karriova_app/features/assessment/pages/enhanced_career_blueprint_page.dart';

class CareerRoadmapPage extends StatelessWidget {
  const CareerRoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TESTING MODE: Skip to carousel directly
    // TODO: Restore auth check after testing
    return _buildReadyState(context);

    // Original code (commented for testing):
    // return BlocBuilder<AuthBloc, AuthState>(
    //   builder: (context, authState) {
    //     final hasCompletedKit = authState.assessmentCompleted == true;
    //     return hasCompletedKit
    //         ? _buildReadyState(context)
    //         : _buildTakeKitPrompt(context);
    //   },
    // );
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

    // Original code (commented for testing):
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Career Roadmap'),
    //     centerTitle: true,
    //     backgroundColor: AppColors.white,
    //     foregroundColor: AppColors.textPrimary,
    //   ),
    //   body: Center(
    //     child: Padding(
    //       padding: const EdgeInsets.all(24),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           const Icon(Icons.trending_up, size: 72, color: AppColors.primary),
    //           const SizedBox(height: 16),
    //           const Text(
    //             'Your Career Portal is Ready',
    //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    //             textAlign: TextAlign.center,
    //           ),
    //           const SizedBox(height: 10),
    //           const Text(
    //             'You have completed KIT. Open your career options below.',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(color: AppColors.textSecondary),
    //           ),
    //           const SizedBox(height: 24),
    //           GradientButton(
    //             text: 'Open Career Options',
    //             onPressed: () => context.go(
    //               AppRouter.careerBlueprintCarousel
    //                   .replaceFirst(':attemptId', 'latest'),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
