import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/routes/app_router.dart';
import 'package:karriova_app/core/services/feedback_service.dart';
import 'package:karriova_app/core/network/api_client.dart';
import 'package:karriova_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:karriova_app/features/auth/presentation/bloc/auth_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 16),
              _buildSection(
                context,
                title: 'Account',
                items: [
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    subtitle: 'Control your privacy settings',
                    onTap: () => context.push(AppRouter.settingsPrivacy),
                  ),
                ],
              ),
              _buildSection(
                context,
                title: 'Preferences',
                items: [
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () => context.push(AppRouter.settingsNotifications),
                  ),
                  _SettingsItem(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    subtitle: 'Theme settings',
                    onTap: () => context.push(AppRouter.settingsAppearance),
                  ),
                ],
              ),
              _buildSection(
                context,
                title: 'Support',
                items: [
                  _SettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () => context.push(AppRouter.settingsHelp),
                  ),
                  _SettingsItem(
                    icon: Icons.feedback_outlined,
                    title: 'Send Feedback',
                    subtitle: 'Help us improve Karriova',
                    onTap: () => _showFeedbackDialog(context),
                  ),
                  _SettingsItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and legal',
                    onTap: () => context.push(AppRouter.settingsAbout),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    onPressed: () => _showLogoutConfirmation(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Log Out'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.primary),
                    title: Text(item.title),
                    subtitle: Text(
                      item.subtitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Theme.of(context).disabledColor),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: 56, color: Theme.of(context).dividerColor),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    final subjectController = TextEditingController();
    String selectedCategory = 'other';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Send Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Help us improve Karriova!'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'bug', child: Text('Bug Report')),
                    DropdownMenuItem(value: 'feature_request', child: Text('Feature Request')),
                    DropdownMenuItem(value: 'complaint', child: Text('Complaint')),
                    DropdownMenuItem(value: 'question', child: Text('Question')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Brief summary...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Please provide details...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final subject = subjectController.text.trim();
                      final description = feedbackController.text.trim();

                      if (subject.isEmpty || description.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        final feedbackService = FeedbackService(ApiClient());
                        await feedbackService.submitFeedback(
                          subject: subject,
                          description: description,
                          category: selectedCategory,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thank you for your feedback! We\'ll review it soon.'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to submit feedback: ${e.toString()}'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
