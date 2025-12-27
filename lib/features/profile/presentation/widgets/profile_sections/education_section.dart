import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../edit_forms/profile_item_dialog.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';
import '../../bloc/profile_event.dart';
import '../../../domain/models/profile_model.dart';

/// Education section - displays educational background
class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return const Center(child: Text('No profile data'));
        }

        // Get real education data from profile
        final educationList = state.profile!.education;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (educationList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No education added yet',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your education',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...educationList.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EducationCard(
                          education: entry.value,
                          index: entry.key,
                        ),
                      ),
                    ),
                  const SizedBox(height: 60), // Space for floating button
                ],
              ),
            ),
            // Floating Add Button
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const ProfileItemDialog(
                      type: ProfileItemType.education,
                    ),
                  );
                  if (result != null && context.mounted) {
                    context.read<ProfileBloc>().add(
                      ProfileEducationAdded(
                        degree: result['degree'] as String,
                        institution: result['institution'] as String,
                        startDate: result['startDate'] as DateTime,
                        endDate: result['endDate'] as DateTime,
                        grade: result['grade'] as String? ?? '',
                        achievements: (result['achievements'] as List<dynamic>?)?.cast<String>() ?? [],
                      ),
                    );
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Education card widget
class EducationCard extends StatelessWidget {
  final Education education;
  final int index;

  const EducationCard({
    super.key,
    required this.education,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Section - Institution Info
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Degree
                        Text(
                          education.degree,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Institution
                        Text(
                          education.institution,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Period
                        Text(
                          _formatDateRange(education.startDate, education.endDate),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  color: AppColors.divider,
                ),

                // Right Section - Achievements & Grade
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grade Badge
                        if (education.grade.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.gradientStart,
                                  AppColors.gradientEnd,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              education.grade,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Achievements Label
                        const Text(
                          'Achievements:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Achievements List
                        ...education.achievements.map(
                          (achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    achievement,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Edit/Delete menu - positioned on top
        Positioned(
          top: 8,
          right: 8,
          child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'edit') {
                  final educationData = {
                    'degree': education.degree,
                    'institution': education.institution,
                    'startDate': education.startDate,
                    'endDate': education.endDate,
                    'grade': education.grade,
                    'achievements': education.achievements,
                  };
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => ProfileItemDialog(
                      type: ProfileItemType.education,
                      initialData: educationData,
                    ),
                  );
                  if (result != null && context.mounted) {
                    context.read<ProfileBloc>().add(
                      ProfileEducationUpdated(
                        index: index,
                        degree: result['degree'] as String,
                        institution: result['institution'] as String,
                        startDate: result['startDate'] as DateTime,
                        endDate: result['endDate'] as DateTime,
                        grade: result['grade'] as String? ?? '',
                        achievements: (result['achievements'] as List<dynamic>?)?.cast<String>() ?? [],
                      ),
                    );
                  }
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Education'),
                      content: Text('Are you sure you want to delete "${education.degree}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<ProfileBloc>().add(
                      ProfileEducationDeleted(index: index),
                    );
                  }
                }
              },
            ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime startDate, DateTime endDate) {
    final dateFormat = DateFormat('MMM yyyy');
    final start = dateFormat.format(startDate);
    final end = dateFormat.format(endDate);
    return '$start - $end';
  }
}
