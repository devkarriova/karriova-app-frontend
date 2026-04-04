import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';
import '../../bloc/profile_event.dart';

/// About section - displays user bio, academic info, and career goals
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (!state.hasProfile) {
          return Builder(
            builder: (context) => Center(
              child: Text(
                'No profile data available',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ),
          );
        }

        final profile = state.profile!;
        final bio = profile.bio;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Card
              _buildCard(
                context: context,
                title: 'About',
                onEdit: () => _showEditBioDialog(context, bio),
                child: bio.isNotEmpty
                    ? Text(
                        bio,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      )
                    : Builder(
                        builder: (context) => Text(
                          'No bio added yet. Click edit to add your bio.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Academic Info Card (Student Profile)
              if (profile.board.isNotEmpty || profile.classGrade.isNotEmpty || profile.schoolName.isNotEmpty)
                ...[
                  _buildCard(
                    context: context,
                    title: 'Academic Info',
                    onEdit: () => _showEditAcademicInfoDialog(
                      context,
                      profile.board,
                      profile.classGrade,
                      profile.schoolName,
                      profile.stream,
                      profile.gender,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile.schoolName.isNotEmpty)
                          _buildInfoRow(Icons.school, 'School/College', profile.schoolName),
                        if (profile.classGrade.isNotEmpty)
                          _buildInfoRow(Icons.class_outlined, 'Class/Grade', profile.classGrade),
                        if (profile.board.isNotEmpty)
                          _buildInfoRow(Icons.account_balance, 'Board', profile.board),
                        if (profile.stream.isNotEmpty)
                          _buildInfoRow(Icons.category, 'Stream', profile.stream),
                        if (profile.gender.isNotEmpty)
                          _buildInfoRow(Icons.person_outline, 'Gender', profile.gender),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

              // Interests Card
              if (profile.generalInterests.isNotEmpty)
                ...[
                  _buildCard(
                    context: context,
                    title: 'Interests',
                    onEdit: () => _showEditInterestsDialog(context, profile.generalInterests),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.generalInterests.map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B9D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFF6B9D).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF6B9D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

              // Career Goals Card
              _buildCard(
                context: context,
                title: 'Career Goals',
                onEdit: () => _showEditCareerGoalsDialog(
                  context,
                  profile.careerGoalStatus,
                  profile.careerGoalText,
                ),
                child: profile.careerGoalStatus.isNotEmpty || profile.careerGoalText.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (profile.careerGoalStatus.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: _getCareerStatusColor(profile.careerGoalStatus).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getCareerStatusColor(profile.careerGoalStatus).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                profile.careerGoalStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getCareerStatusColor(profile.careerGoalStatus),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (profile.careerGoalText.isNotEmpty)
                            Text(
                              profile.careerGoalText,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                        ],
                      )
                    : Builder(
                        builder: (context) => Text(
                          'No career goals added yet',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCareerStatusColor(String status) {
    if (status.toLowerCase().contains('sure')) {
      return Colors.green;
    } else if (status.toLowerCase().contains('unsure')) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBioDialog(BuildContext context, String currentBio) {
    final profileBloc = context.read<ProfileBloc>();
    final TextEditingController bioController = TextEditingController(text: currentBio);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit About'),
        content: TextField(
          controller: bioController,
          maxLines: 6,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newBio = bioController.text.trim();
              profileBloc.add(
                ProfilePersonalDetailsUpdated(bio: newBio),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => bioController.dispose());
  }

  void _showEditAcademicInfoDialog(
    BuildContext context,
    String currentBoard,
    String currentClass,
    String currentSchool,
    String currentStream,
    String currentGender,
  ) {
    final profileBloc = context.read<ProfileBloc>();
    final boardController = TextEditingController(text: currentBoard);
    final classController = TextEditingController(text: currentClass);
    final schoolController = TextEditingController(text: currentSchool);
    final streamController = TextEditingController(text: currentStream);
    final genderController = TextEditingController(text: currentGender);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Academic Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: schoolController,
                decoration: const InputDecoration(
                  labelText: 'School/College Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: classController,
                decoration: const InputDecoration(
                  labelText: 'Class/Grade',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: boardController,
                decoration: const InputDecoration(
                  labelText: 'Board (CBSE/ICSE/State)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streamController,
                decoration: const InputDecoration(
                  labelText: 'Stream (Science/Commerce/Arts)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              profileBloc.add(
                ProfileOnboardingUpdated(
                  board: boardController.text.trim(),
                  classGrade: classController.text.trim(),
                  schoolName: schoolController.text.trim(),
                  stream: streamController.text.trim(),
                  gender: genderController.text.trim(),
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      boardController.dispose();
      classController.dispose();
      schoolController.dispose();
      streamController.dispose();
      genderController.dispose();
    });
  }

  void _showEditInterestsDialog(BuildContext context, List<String> currentInterests) {
    final profileBloc = context.read<ProfileBloc>();
    final interestsController = TextEditingController(text: currentInterests.join(', '));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Interests'),
        content: TextField(
          controller: interestsController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter interests separated by commas',
            helperText: 'e.g., Reading, Sports, Music, Coding',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final interests = interestsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              profileBloc.add(
                ProfileOnboardingUpdated(generalInterests: interests),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => interestsController.dispose());
  }

  void _showEditCareerGoalsDialog(
    BuildContext context,
    String currentStatus,
    String currentGoal,
  ) {
    final profileBloc = context.read<ProfileBloc>();
    const statusOptions = [
      'Sure about my career path',
      'Unsure between options',
      'Need help deciding',
    ];

    String normalizeStatus(String raw) {
      final value = raw.trim().toLowerCase().replaceAll('.', '');
      if (value.contains('unsure between')) return 'Unsure between options';
      if (value == 'unsure' || value.contains('unsure')) return 'Unsure between options';
      if (value == 'need help' || value.contains('need help')) return 'Need help deciding';
      if (value == 'sure' || value.contains('sure')) return 'Sure about my career path';
      return '';
    }

    String selectedStatus = normalizeStatus(currentStatus);
    if (!statusOptions.contains(selectedStatus)) {
      selectedStatus = statusOptions.first;
    }
    final goalController = TextEditingController(text: currentGoal);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Career Goals'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: statusOptions.contains(selectedStatus) ? selectedStatus : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: statusOptions
                      .toSet()
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: goalController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Career Goal',
                    hintText: 'Describe your career aspirations...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                profileBloc.add(
                  ProfileOnboardingUpdated(
                    careerGoalStatus: selectedStatus,
                    careerGoalText: goalController.text.trim(),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ).then((_) => goalController.dispose());
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required Widget child,
    required VoidCallback onEdit,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: isDark ? [] : [
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
          // Title and Edit Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16),
                onPressed: onEdit,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                iconSize: 16,
                color: theme.textTheme.bodyMedium?.color,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
