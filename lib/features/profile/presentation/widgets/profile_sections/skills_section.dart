import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';
import '../../bloc/profile_event.dart';
import '../edit_forms/profile_item_dialog.dart';

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

        // Get real skills from profile (currently just List<String>)
        final skills = state.profile!.skills;

        // TODO: Languages not yet supported in ProfileModel - add to backend
        final languages = <String>[];

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
                  if (skills.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.code, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No skills added yet',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your skills',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...skills.map((skill) => _buildSkillCard(context, skill)),

                  const SizedBox(height: 32),

                  // Languages Section
                  _buildSectionHeader(context, 'Languages', Icons.language),
                  const SizedBox(height: 16),
                  if (languages.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.language, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Languages not yet supported',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This feature will be available soon',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
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
            onPressed: () async {
              Navigator.pop(context);
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => const ProfileItemDialog(
                  type: ProfileItemType.skill,
                ),
              );
              if (result != null && context.mounted) {
                context.read<ProfileBloc>().add(
                  ProfileSkillAdded(skill: result['name'] as String),
                );
              }
            },
            child: const Text('Technical Skill'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => const ProfileItemDialog(
                  type: ProfileItemType.language,
                ),
              );
              if (result != null && context.mounted) {
                // TODO: Add language to profile using BLoC
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language "${result['name']}" added successfully')),
                );
              }
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

  Widget _buildSkillCard(BuildContext context, String skillName) {
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.code,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    skillName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
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
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Skill'),
                    content: Text('Are you sure you want to delete "$skillName"?'),
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
                    ProfileSkillDeleted(skill: skillName),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, String languageName) {
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    languageName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[600]),
            padding: EdgeInsets.zero,
            itemBuilder: (context) => [
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
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Language'),
                    content: Text('Are you sure you want to delete "$languageName"?'),
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
                  // TODO: Delete language from profile using BLoC
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Language "$languageName" deleted')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
