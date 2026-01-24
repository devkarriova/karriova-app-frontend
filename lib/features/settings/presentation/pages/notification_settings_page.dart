import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Push notification settings
  bool _pushEnabled = true;
  bool _pushLikes = true;
  bool _pushComments = true;
  bool _pushFollows = true;
  bool _pushMessages = true;
  bool _pushJobAlerts = true;

  // Email notification settings
  bool _emailEnabled = true;
  bool _emailWeeklyDigest = true;
  bool _emailJobMatches = true;
  bool _emailPromotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Push Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Push Notifications'),
                subtitle: const Text('Receive notifications on your device'),
                value: _pushEnabled,
                onChanged: (value) {
                  setState(() => _pushEnabled = value);
                },
              ),
              if (_pushEnabled) ...[
                const Divider(indent: 16, endIndent: 16),
                _buildSubSetting(
                  title: 'Likes',
                  subtitle: 'When someone likes your post',
                  value: _pushLikes,
                  onChanged: (value) => setState(() => _pushLikes = value),
                ),
                _buildSubSetting(
                  title: 'Comments',
                  subtitle: 'When someone comments on your post',
                  value: _pushComments,
                  onChanged: (value) => setState(() => _pushComments = value),
                ),
                _buildSubSetting(
                  title: 'Follows',
                  subtitle: 'When someone follows you',
                  value: _pushFollows,
                  onChanged: (value) => setState(() => _pushFollows = value),
                ),
                _buildSubSetting(
                  title: 'Messages',
                  subtitle: 'When you receive a new message',
                  value: _pushMessages,
                  onChanged: (value) => setState(() => _pushMessages = value),
                ),
                _buildSubSetting(
                  title: 'Job Alerts',
                  subtitle: 'When new jobs match your profile',
                  value: _pushJobAlerts,
                  onChanged: (value) => setState(() => _pushJobAlerts = value),
                ),
              ],
            ],
          ),
          _buildSection(
            context,
            title: 'Email Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Email Notifications'),
                subtitle: const Text('Receive updates via email'),
                value: _emailEnabled,
                onChanged: (value) {
                  setState(() => _emailEnabled = value);
                },
              ),
              if (_emailEnabled) ...[
                const Divider(indent: 16, endIndent: 16),
                _buildSubSetting(
                  title: 'Weekly Digest',
                  subtitle: 'Summary of activity and updates',
                  value: _emailWeeklyDigest,
                  onChanged: (value) => setState(() => _emailWeeklyDigest = value),
                ),
                _buildSubSetting(
                  title: 'Job Matches',
                  subtitle: 'Jobs that match your profile',
                  value: _emailJobMatches,
                  onChanged: (value) => setState(() => _emailJobMatches = value),
                ),
                _buildSubSetting(
                  title: 'Promotions & Tips',
                  subtitle: 'Product updates and career tips',
                  value: _emailPromotions,
                  onChanged: (value) => setState(() => _emailPromotions = value),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Settings'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSubSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _saveSettings() {
    // TODO: Save notification settings to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
