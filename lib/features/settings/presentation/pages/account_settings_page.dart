import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/services/user_data_service.dart';
import 'package:karriova_app/core/network/api_client.dart';
import 'package:karriova_app/features/settings/presentation/pages/terms_of_service_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late final UserDataService _userDataService;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _userDataService = UserDataService(ApiClient());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info text
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Manage your account settings and preferences. To edit your profile information, please visit your Profile page.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),

            // Danger Zone
              Text(
                'Danger Zone',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: AppColors.error.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.pause_circle_outline,
                            color: AppColors.warning),
                        title: const Text('Deactivate Account'),
                        subtitle: const Text(
                          'Temporarily disable your account',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () => _showDeactivateDialog(context),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.delete_forever,
                            color: AppColors.error),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(color: AppColors.error),
                        ),
                        subtitle: const Text(
                          'Permanently delete your account and data',
                          style: TextStyle(fontSize: 12),
                        ),
                        onTap: () => _showDeleteDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Your account will be temporarily disabled. You can reactivate it by logging in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Deactivate account
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted, including:',
            ),
            const SizedBox(height: 12),
            const Text('• Your profile and posts'),
            const Text('• Your messages and connections'),
            const Text('• Your assessment history'),
            const Text('• All associated data'),
            const SizedBox(height: 16),
            const Text(
              'Type "DELETE" to confirm:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'DELETE',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          StatefulBuilder(
            builder: (context, setDialogState) {
              return ElevatedButton(
                onPressed: _isDeleting
                    ? null
                    : () async {
                        if (confirmController.text != 'DELETE') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please type DELETE to confirm'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        
                        setDialogState(() => _isDeleting = true);
                        
                        try {
                          await _userDataService.deleteAccount();
                          if (context.mounted) {
                            Navigator.pop(context);
                            // Navigate to login and clear all routes
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          setDialogState(() => _isDeleting = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete account: ${e.toString()}'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: _isDeleting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      )
                    : const Text('Delete'),
              );
            },
          ),
        ],
      ),
    );
  }
}
