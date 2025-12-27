import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';
import '../../bloc/profile_event.dart';
import '../edit_forms/profile_item_dialog.dart';
import '../../../domain/models/profile_model.dart';

/// Experience section - displays work experience with timeline progression
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return const Center(child: Text('No profile data'));
        }

        // Get real experience data from profile
        final experiences = state.profile!.experience;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context),
                  const SizedBox(height: 24),
                  _buildTimelineList(experiences),
                  const SizedBox(height: 80), // Space for floating button
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
                      type: ProfileItemType.experience,
                    ),
                  );
                  if (result != null && context.mounted) {
                    context.read<ProfileBloc>().add(
                      ProfileExperienceAdded(
                        title: result['jobTitle'] as String,
                        company: result['companyName'] as String,
                        companyId: '', // TODO: Get from company search
                        location: result['location'] as String,
                        startDate: result['startDate'] as DateTime,
                        endDate: result['endDate'] as DateTime?,
                        current: result['isCurrent'] as bool? ?? false,
                        description: result['description'] as String? ?? '',
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

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.work_outline, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        const Text(
          'Work Experience',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineList(List<Experience> experiences) {
    if (experiences.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No work experience added yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add your work experience',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(experiences.length, (index) {
        final experience = experiences[index];
        final isLast = index == experiences.length - 1;
        return Builder(
          builder: (context) => _buildTimelineItem(context, experience, isLast, index),
        );
      }),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Experience experience, bool isLast, int index) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Experience card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title and action buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          experience.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Edit and Delete buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
                            onPressed: () async {
                              final experienceMap = {
                                'jobTitle': experience.title,
                                'companyName': experience.company,
                                'location': experience.location,
                                'startDate': experience.startDate,
                                'endDate': experience.endDate,
                                'isCurrent': experience.current,
                                'description': experience.description,
                                'employmentType': null, // Not in Experience model currently
                              };
                              final result = await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) => ProfileItemDialog(
                                  type: ProfileItemType.experience,
                                  initialData: experienceMap,
                                ),
                              );
                              if (result != null && context.mounted) {
                                context.read<ProfileBloc>().add(
                                  ProfileExperienceUpdated(
                                    index: index,
                                    title: result['jobTitle'] as String,
                                    company: result['companyName'] as String,
                                    companyId: '', // TODO: Get from company search
                                    location: result['location'] as String,
                                    startDate: result['startDate'] as DateTime,
                                    endDate: result['endDate'] as DateTime?,
                                    current: result['isCurrent'] as bool? ?? false,
                                    description: result['description'] as String? ?? '',
                                  ),
                                );
                              }
                            },
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Experience'),
                                  content: Text('Are you sure you want to delete "${experience.title}"?'),
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
                                  ProfileExperienceDeleted(index: index),
                                );
                              }
                            },
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Company name
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        experience.company,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date range
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateRange(
                          experience.startDate,
                          experience.endDate,
                          experience.current,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        experience.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (experience.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      experience.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime startDate, DateTime? endDate, bool isCurrent) {
    final dateFormat = DateFormat('MMM yyyy');
    final start = dateFormat.format(startDate);

    if (isCurrent) {
      return '$start - Present';
    } else if (endDate != null) {
      final end = dateFormat.format(endDate);
      return '$start - $end';
    }

    return start;
  }
}
