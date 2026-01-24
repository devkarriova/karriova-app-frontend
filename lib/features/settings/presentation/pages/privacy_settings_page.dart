import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  // Profile visibility
  String _profileVisibility = 'public'; // public, connections, private

  // Privacy settings
  bool _showEmail = false;
  bool _showPhone = false;
  bool _showLocation = true;
  bool _allowMessagesFromAnyone = true;
  bool _showOnlineStatus = true;
  bool _allowProfileInSearch = true;

  // Activity settings
  bool _showActivityStatus = true;
  bool _shareProfileViews = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Profile Visibility',
            children: [
              RadioListTile<String>(
                title: const Text('Public'),
                subtitle: const Text('Anyone can see your profile'),
                value: 'public',
                groupValue: _profileVisibility,
                onChanged: (value) {
                  setState(() => _profileVisibility = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Connections Only'),
                subtitle: const Text('Only your connections can see your profile'),
                value: 'connections',
                groupValue: _profileVisibility,
                onChanged: (value) {
                  setState(() => _profileVisibility = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Private'),
                subtitle: const Text('Only you can see your profile'),
                value: 'private',
                groupValue: _profileVisibility,
                onChanged: (value) {
                  setState(() => _profileVisibility = value!);
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Contact Information',
            children: [
              SwitchListTile(
                title: const Text('Show Email Address'),
                subtitle: const Text('Display your email on your profile'),
                value: _showEmail,
                onChanged: (value) {
                  setState(() => _showEmail = value);
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              SwitchListTile(
                title: const Text('Show Phone Number'),
                subtitle: const Text('Display your phone number on your profile'),
                value: _showPhone,
                onChanged: (value) {
                  setState(() => _showPhone = value);
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              SwitchListTile(
                title: const Text('Show Location'),
                subtitle: const Text('Display your city/country on your profile'),
                value: _showLocation,
                onChanged: (value) {
                  setState(() => _showLocation = value);
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Messaging',
            children: [
              SwitchListTile(
                title: const Text('Allow Messages from Anyone'),
                subtitle: const Text(
                  'Anyone can send you messages. If off, only connections can message you.',
                ),
                value: _allowMessagesFromAnyone,
                onChanged: (value) {
                  setState(() => _allowMessagesFromAnyone = value);
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Activity',
            children: [
              SwitchListTile(
                title: const Text('Show Online Status'),
                subtitle: const Text('Let others see when you\'re active'),
                value: _showOnlineStatus,
                onChanged: (value) {
                  setState(() => _showOnlineStatus = value);
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              SwitchListTile(
                title: const Text('Show Activity Status'),
                subtitle: const Text('Show your recent activity to connections'),
                value: _showActivityStatus,
                onChanged: (value) {
                  setState(() => _showActivityStatus = value);
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              SwitchListTile(
                title: const Text('Share Profile Views'),
                subtitle: const Text(
                  'Let others know when you view their profile',
                ),
                value: _shareProfileViews,
                onChanged: (value) {
                  setState(() => _shareProfileViews = value);
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Discoverability',
            children: [
              SwitchListTile(
                title: const Text('Allow Profile in Search'),
                subtitle: const Text(
                  'Your profile can appear in search results',
                ),
                value: _allowProfileInSearch,
                onChanged: (value) {
                  setState(() => _allowProfileInSearch = value);
                },
              ),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: _downloadData,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Download My Data'),
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

  void _saveSettings() {
    // TODO: Save privacy settings to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadData() {
    // TODO: Request data download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export request submitted. You will receive an email when ready.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
