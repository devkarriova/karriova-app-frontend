import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/profile_model.dart';

class SkillsEditForm extends StatelessWidget {
  final ProfileModel profile;

  const SkillsEditForm({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Column(
          children: [
            Icon(Icons.stars_outlined, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 16),
            Text(
              'Skills Management',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
