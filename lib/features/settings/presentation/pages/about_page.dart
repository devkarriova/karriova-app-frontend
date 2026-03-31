import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/routes/app_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _appVersion = '1.0.0';
  static const String _buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          // App Logo and Version
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Karriova',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (context) => Text(
                    'Version $_appVersion ($_buildNumber)',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            title: 'About Karriova',
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Karriova is a professional networking platform that connects job seekers with opportunities and helps professionals build meaningful career connections.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Legal',
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.termsOfService),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRouter.privacyPolicy),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Icons.cookie_outlined),
                title: const Text('Cookie Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _launchUrl('https://karriova.com/cookies'),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: const Text('Licenses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Karriova',
                    applicationVersion: _appVersion,
                    applicationIcon: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.work_outline,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Connect With Us',
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Website'),
                subtitle: const Text('karriova.com'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl('https://karriova.com'),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Contact Support'),
                subtitle: const Text('support@karriova.com'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _launchUrl('mailto:support@karriova.com'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Builder(
              builder: (context) => Text(
                '© ${DateTime.now().year} Karriova. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
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

  void _launchUrl(String urlString) {
    // TODO: Add url_launcher package and implement
    // Placeholder until url_launcher is integrated.
  }
}
