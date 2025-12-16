import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';

/// Skills section - displays user skills with ratings and languages
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return const Center(child: Text('No profile data'));
        }

        // Mock data for demonstration - replace with actual data when backend is ready
        final skills = _getMockSkills();
        final languages = _getMockLanguages();

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skills Section
                  _buildSectionHeader(context, 'Technical Skills', Icons.code),
                  const SizedBox(height: 16),
                  ...skills.map((skill) => _buildSkillCard(context, skill)),

                  const SizedBox(height: 32),

                  // Languages Section
                  _buildSectionHeader(context, 'Languages', Icons.language),
                  const SizedBox(height: 16),
                  ...languages.map((language) => _buildLanguageCard(context, language)),

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
                  // TODO: Show dialog to add skill or language
                  _showAddSkillDialog(context);
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

  void _showAddSkillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Skills'),
        content: const Text('Would you like to add a technical skill or a language?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add skill functionality coming soon')),
              );
            },
            child: const Text('Technical Skill'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add language functionality coming soon')),
              );
            },
            child: const Text('Language'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillCard(BuildContext context, Map<String, dynamic> skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (skill['yearsOfExperience'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${skill['yearsOfExperience']} years of experience',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStarRating(skill['rating'] as int),
                  const SizedBox(width: 8),
                  // Edit and Delete buttons
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
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
                    onSelected: (value) {
                      if (value == 'edit') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit skill functionality coming soon')),
                        );
                      } else if (value == 'delete') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Delete skill functionality coming soon')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, Map<String, dynamic> language) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              language['name'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              language['proficiency'] as String,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Edit and Delete menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
            padding: EdgeInsets.zero,
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
            onSelected: (value) {
              if (value == 'edit') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit language functionality coming soon')),
                );
              } else if (value == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete language functionality coming soon')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: AppColors.primary,
          size: 20,
        );
      }),
    );
  }

  // Mock data - replace with actual data from backend
  List<Map<String, dynamic>> _getMockSkills() {
    return [
      {'name': 'Flutter', 'rating': 5, 'yearsOfExperience': 3},
      {'name': 'Dart', 'rating': 5, 'yearsOfExperience': 3},
      {'name': 'React', 'rating': 4, 'yearsOfExperience': 2},
      {'name': 'Node.js', 'rating': 4, 'yearsOfExperience': 2},
      {'name': 'Python', 'rating': 3, 'yearsOfExperience': 1},
    ];
  }

  List<Map<String, dynamic>> _getMockLanguages() {
    return [
      {'name': 'English', 'proficiency': 'Native'},
      {'name': 'Spanish', 'proficiency': 'Professional'},
      {'name': 'French', 'proficiency': 'Intermediate'},
    ];
  }
}
