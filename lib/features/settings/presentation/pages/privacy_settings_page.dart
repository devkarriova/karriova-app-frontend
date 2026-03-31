import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/routes/app_router.dart';
import 'package:karriova_app/core/services/user_data_service.dart';
import 'package:karriova_app/core/services/user_settings_service.dart';
import 'package:karriova_app/core/network/api_client.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  final _settingsService = GetIt.instance<UserSettingsService>();
  late final UserDataService _userDataService;
  
  // Loading state
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isExporting = false;
  String? _error;

  // Profile visibility
  String _profileVisibility = 'public'; // public, connections, private

  // Privacy settings
  bool _showEmail = false;
  bool _showPhone = false;
  bool _showLocation = true;
  bool _allowMessagesFromAnyone = true;
  bool _allowProfileInSearch = true;

  @override
  void initState() {
    super.initState();
    _userDataService = UserDataService(ApiClient());
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final settings = await _settingsService.getPrivacySettings();
      
      setState(() {
        _profileVisibility = settings.profileVisibility;
        _showEmail = settings.showEmail;
        _showPhone = settings.showPhone;
        _showLocation = settings.showLocation;
        _allowMessagesFromAnyone = settings.allowMessagesFromAnyone;
        _allowProfileInSearch = settings.allowProfileInSearch;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Privacy'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Privacy'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load settings', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadSettings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

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
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Settings'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _isExporting ? null : _downloadData,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? 'Exporting...' : 'Download My Data'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                context.push(AppRouter.privacyPolicy);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.description_outlined),
              label: const Text('View Privacy Policy'),
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
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      await _settingsService.updatePrivacySettings(
        PrivacySettings(
          profileVisibility: _profileVisibility,
          showEmail: _showEmail,
          showPhone: _showPhone,
          showLocation: _showLocation,
          allowMessagesFromAnyone: _allowMessagesFromAnyone,
          allowProfileInSearch: _allowProfileInSearch,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy settings saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _downloadData() async {
    setState(() => _isExporting = true);
    
    try {
      await _userDataService.exportUserDataToFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data export ready! Check your downloads.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
