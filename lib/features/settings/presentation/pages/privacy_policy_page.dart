import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: February 15, 2026',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '1. Introduction',
              content: '''
Karriova ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.

We take your privacy seriously and are committed to compliance with applicable data protection laws, including the General Data Protection Regulation (GDPR) and other relevant privacy regulations.

Please read this Privacy Policy carefully. By using Karriova, you consent to the practices described in this policy.
''',
            ),
            _buildSection(
              context,
              title: '2. Information We Collect',
              content: '''
We collect information you provide directly and information collected automatically:

INFORMATION YOU PROVIDE:
• Account Information: Name, email address, password, phone number
• Profile Information: Photo, headline, summary, location, work experience, education, skills, certifications, languages, and projects
• Assessment Data: Responses to professional assessments (like the Karriova Insight Test)
• Content: Posts, comments, messages, and other content you create
• Communications: Feedback, support requests, and correspondence with us

AUTOMATICALLY COLLECTED INFORMATION:
• Device Information: Device type, operating system, unique device identifiers
• Usage Data: Features used, actions taken, time spent on the app
• Log Data: IP address, access times, pages viewed, app crashes
• Location Data: General location based on IP address (we do not collect precise GPS location)
''',
            ),
            _buildSection(
              context,
              title: '3. How We Use Your Information',
              content: '''
We use your information for the following purposes:

SERVICE DELIVERY:
• Create and manage your account
• Provide personalized content and recommendations
• Enable networking and communication features
• Process and display assessment results
• Send notifications about activity on your account

IMPROVEMENT & ANALYTICS:
• Analyze usage patterns to improve our services
• Develop new features and functionality
• Conduct research and analytics
• Debug and fix technical issues

COMMUNICATIONS:
• Send service-related announcements
• Respond to your inquiries and support requests
• Send promotional communications (with your consent)

SAFETY & LEGAL:
• Detect and prevent fraud, abuse, and security threats
• Enforce our Terms of Service
• Comply with legal obligations
''',
            ),
            _buildSection(
              context,
              title: '4. Legal Basis for Processing (GDPR)',
              content: '''
For users in the European Economic Area (EEA), we process personal data under the following legal bases:

• CONTRACTUAL NECESSITY: To provide our services as described in our Terms of Service
• LEGITIMATE INTERESTS: For analytics, security, and service improvement
• CONSENT: For optional features like marketing communications
• LEGAL OBLIGATION: To comply with applicable laws and regulations

You may withdraw consent at any time where processing is based on consent. This will not affect the lawfulness of processing before withdrawal.
''',
            ),
            _buildSection(
              context,
              title: '5. Information Sharing',
              content: '''
We do not sell your personal information. We may share information in these circumstances:

WITH OTHER USERS:
• Your public profile information (name, photo, headline, etc.)
• Content you post publicly
• Professional information you choose to share

WITH SERVICE PROVIDERS:
• Cloud hosting providers (Google Cloud Platform)
• Analytics services
• Email service providers
• Authentication providers (Google Sign-In)

These providers are contractually obligated to protect your data and use it only for the services they provide to us.

FOR LEGAL REASONS:
• To comply with legal process or government requests
• To protect rights, privacy, safety, or property
• To enforce our Terms of Service
• In connection with a merger, acquisition, or sale of assets

AGGREGATED DATA:
We may share anonymized, aggregated data that cannot identify you for research and analytics purposes.
''',
            ),
            _buildSection(
              context,
              title: '6. Data Retention',
              content: '''
We retain your personal information for as long as necessary to:

• Provide our services to you
• Comply with legal obligations
• Resolve disputes and enforce agreements
• Maintain business records

RETENTION PERIODS:
• Account data: Retained while your account is active, plus 30 days after deletion request
• Posts and content: Retained until you delete them or your account
• Assessment results: Retained for 3 years or until account deletion
• Log data: Retained for 12 months
• Backup data: Retained for up to 90 days after deletion

When you delete your account, we will delete or anonymize your personal information within 30 days, except where we need to retain it for legal purposes.
''',
            ),
            _buildSection(
              context,
              title: '7. Your Rights',
              content: '''
You have the following rights regarding your personal information:

ACCESS: Request a copy of your personal data (available in Settings > Privacy > Download My Data)

CORRECTION: Update or correct inaccurate information through your profile settings

DELETION: Request deletion of your account and personal data (Settings > Account > Delete Account)

PORTABILITY: Receive your data in a structured, machine-readable format

RESTRICTION: Request limitation of processing in certain circumstances

OBJECTION: Object to processing based on legitimate interests

WITHDRAW CONSENT: Withdraw consent for optional processing at any time

To exercise these rights, use the in-app settings or contact us at privacy@karriova.com. We will respond within 30 days.
''',
            ),
            _buildSection(
              context,
              title: '8. Data Security',
              content: '''
We implement appropriate technical and organizational measures to protect your personal information:

TECHNICAL MEASURES:
• Encryption of data in transit (TLS/SSL)
• Encryption of sensitive data at rest
• Secure password hashing (bcrypt)
• Regular security assessments and updates

ORGANIZATIONAL MEASURES:
• Access controls and authentication
• Employee training on data protection
• Incident response procedures
• Regular security audits

While we strive to protect your information, no method of transmission or storage is 100% secure. We cannot guarantee absolute security.
''',
            ),
            _buildSection(
              context,
              title: '9. International Data Transfers',
              content: '''
Your information may be transferred to and processed in countries other than your country of residence. These countries may have different data protection laws.

When we transfer data outside the EEA, we ensure appropriate safeguards are in place:

• Standard Contractual Clauses approved by the European Commission
• Transfers to countries with adequate data protection (as determined by the European Commission)
• Other lawful transfer mechanisms

By using Karriova, you consent to the transfer of your information to countries outside your residence.
''',
            ),
            _buildSection(
              context,
              title: '10. Children\'s Privacy',
              content: '''
Karriova is not intended for users under 16 years of age. We do not knowingly collect personal information from children under 16.

If we become aware that we have collected personal information from a child under 16, we will take steps to delete that information promptly.

If you believe we have collected information from a child under 16, please contact us at privacy@karriova.com.
''',
            ),
            _buildSection(
              context,
              title: '11. Cookies and Tracking',
              content: '''
Our mobile app uses limited tracking technologies:

LOCAL STORAGE:
• Authentication tokens for keeping you logged in
• User preferences and settings
• Cached data for performance

ANALYTICS:
• Anonymous usage data to improve our services
• Crash reports to fix technical issues

We do not use cross-site tracking cookies. You can manage notification preferences in the app settings.
''',
            ),
            _buildSection(
              context,
              title: '12. Third-Party Links',
              content: '''
Our app may contain links to third-party websites or services. This Privacy Policy does not apply to those third-party services.

We encourage you to review the privacy policies of any third-party services you access through Karriova.

We are not responsible for the privacy practices of third-party websites or services.
''',
            ),
            _buildSection(
              context,
              title: '13. Changes to This Policy',
              content: '''
We may update this Privacy Policy from time to time. We will notify you of material changes by:

• Posting the updated policy in the app
• Updating the "Last updated" date
• Sending a notification for significant changes

Your continued use of Karriova after changes constitutes acceptance of the updated Privacy Policy.

We encourage you to review this policy periodically.
''',
            ),
            _buildSection(
              context,
              title: '14. Contact Us',
              content: '''
If you have questions about this Privacy Policy or our data practices, please contact us:

Data Protection Officer
Email: privacy@karriova.com
Address: Karriova Inc.

For GDPR-related inquiries, EU residents may also contact our EU representative or lodge a complaint with your local data protection authority.

We aim to respond to all privacy inquiries within 30 days.
''',
            ),
            const SizedBox(height: 32),
            _buildHighlightBox(
              context,
              icon: Icons.download_outlined,
              title: 'Download Your Data',
              description:
                  'You can download a copy of all your personal data from Settings > Privacy > Download My Data',
            ),
            const SizedBox(height: 16),
            _buildHighlightBox(
              context,
              icon: Icons.delete_outline,
              title: 'Delete Your Account',
              description:
                  'You can permanently delete your account and all associated data from Settings > Account > Delete Account',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
