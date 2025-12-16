import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';

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

        // Mock data for demonstration - replace with actual data when backend is ready
        final experiences = _getMockExperiences();

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
                onPressed: () {
                  // TODO: Navigate to add experience page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add experience functionality coming soon'),
                    ),
                  );
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

  Widget _buildTimelineList(List<Map<String, dynamic>> experiences) {
    return Column(
      children: List.generate(experiences.length, (index) {
        final experience = experiences[index];
        final isLast = index == experiences.length - 1;
        return Builder(
          builder: (context) => _buildTimelineItem(context, experience, isLast),
        );
      }),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> experience, bool isLast) {
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
                          experience['jobTitle'] as String,
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
                            onPressed: () {
                              // TODO: Navigate to edit experience page
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Edit experience functionality coming soon'),
                                ),
                              );
                            },
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                            onPressed: () {
                              // TODO: Show confirmation dialog and delete
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Delete experience functionality coming soon'),
                                ),
                              );
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
                        experience['companyName'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date range and employment type
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateRange(
                          experience['startDate'] as DateTime,
                          experience['endDate'] as DateTime?,
                          experience['isCurrent'] as bool,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (experience['employmentType'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            experience['employmentType'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (experience['location'] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          experience['location'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (experience['description'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      experience['description'] as String,
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

  // Mock data - replace with actual data from backend
  List<Map<String, dynamic>> _getMockExperiences() {
    return [
      {
        'jobTitle': 'Senior Flutter Developer',
        'companyName': 'Tech Solutions Inc.',
        'employmentType': 'Full-time',
        'location': 'San Francisco, CA',
        'startDate': DateTime(2022, 1),
        'endDate': null,
        'isCurrent': true,
        'description':
            'Leading the development of cross-platform mobile applications using Flutter. Mentoring junior developers and implementing best practices for code quality and performance.',
      },
      {
        'jobTitle': 'Flutter Developer',
        'companyName': 'Digital Innovations',
        'employmentType': 'Full-time',
        'location': 'Remote',
        'startDate': DateTime(2020, 6),
        'endDate': DateTime(2021, 12),
        'isCurrent': false,
        'description':
            'Developed and maintained multiple mobile applications for clients across various industries. Collaborated with designers and backend developers to deliver high-quality products.',
      },
      {
        'jobTitle': 'Mobile App Developer',
        'companyName': 'StartUp Labs',
        'employmentType': 'Contract',
        'location': 'New York, NY',
        'startDate': DateTime(2019, 3),
        'endDate': DateTime(2020, 5),
        'isCurrent': false,
        'description':
            'Built mobile applications from scratch using Flutter and React Native. Worked directly with stakeholders to understand requirements and deliver MVPs.',
      },
    ];
  }
}
