import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              title: '1. Acceptance of Terms',
              content: '''
By accessing or using Karriova ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.

Karriova is a professional networking and career development platform designed to help users connect, grow professionally, and discover career opportunities.
''',
            ),
            _buildSection(
              context,
              title: '2. Eligibility',
              content: '''
You must be at least 16 years old to use Karriova. By using the App, you represent and warrant that you meet this age requirement and have the legal capacity to enter into these Terms.

If you are using Karriova on behalf of an organization, you represent that you have the authority to bind that organization to these Terms.
''',
            ),
            _buildSection(
              context,
              title: '3. Account Registration',
              content: '''
To use certain features of Karriova, you must create an account. You agree to:

• Provide accurate, current, and complete information during registration
• Maintain and promptly update your account information
• Keep your password secure and confidential
• Accept responsibility for all activities under your account
• Notify us immediately of any unauthorized use of your account

We reserve the right to suspend or terminate accounts that violate these Terms.
''',
            ),
            _buildSection(
              context,
              title: '4. User Conduct',
              content: '''
When using Karriova, you agree NOT to:

• Post false, misleading, or fraudulent content
• Harass, abuse, or harm other users
• Impersonate any person or entity
• Share others' personal information without consent
• Use the platform for spam or unauthorized advertising
• Attempt to gain unauthorized access to our systems
• Use automated tools to scrape or collect data
• Violate any applicable laws or regulations
• Post content that infringes intellectual property rights
• Engage in discrimination or hate speech

We reserve the right to remove content and suspend accounts that violate these guidelines.
''',
            ),
            _buildSection(
              context,
              title: '5. User Content',
              content: '''
You retain ownership of content you post on Karriova. By posting content, you grant us a non-exclusive, worldwide, royalty-free license to use, display, reproduce, and distribute your content in connection with the App.

You are solely responsible for the content you post and its accuracy. We do not endorse any user content and are not liable for content posted by users.

We may remove content that violates these Terms or is otherwise objectionable at our sole discretion.
''',
            ),
            _buildSection(
              context,
              title: '6. Professional Assessments',
              content: '''
Karriova offers professional assessments (including the Karriova Insight Test) to help users understand their professional strengths and preferences. These assessments:

• Are for informational and self-development purposes only
• Should not be considered professional psychological evaluations
• May be retaken periodically as specified in the App
• Results are personal to you and stored securely

Assessment results should be used as one of many tools in your career development journey.
''',
            ),
            _buildSection(
              context,
              title: '7. Privacy',
              content: '''
Your privacy is important to us. Our collection and use of personal information is governed by our Privacy Policy, which is incorporated into these Terms by reference.

By using Karriova, you consent to our collection and use of information as described in the Privacy Policy.
''',
            ),
            _buildSection(
              context,
              title: '8. Intellectual Property',
              content: '''
Karriova and its original content, features, and functionality are owned by Karriova and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.

You may not copy, modify, distribute, sell, or lease any part of our services or included software without our prior written consent.
''',
            ),
            _buildSection(
              context,
              title: '9. Third-Party Services',
              content: '''
Karriova may contain links to third-party websites or services. We are not responsible for the content, privacy policies, or practices of third-party sites.

We may use third-party services for authentication (such as Google Sign-In), analytics, and other functionality. Your use of these services is subject to their respective terms and policies.
''',
            ),
            _buildSection(
              context,
              title: '10. Disclaimer of Warranties',
              content: '''
KARRIOVA IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

We do not warrant that the App will be uninterrupted, secure, or error-free, or that defects will be corrected.
''',
            ),
            _buildSection(
              context,
              title: '11. Limitation of Liability',
              content: '''
TO THE MAXIMUM EXTENT PERMITTED BY LAW, KARRIOVA SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING LOSS OF PROFITS, DATA, OR OTHER INTANGIBLES.

Our total liability shall not exceed the amount you paid us (if any) in the twelve months prior to the claim.
''',
            ),
            _buildSection(
              context,
              title: '12. Indemnification',
              content: '''
You agree to indemnify, defend, and hold harmless Karriova, its officers, directors, employees, and agents from any claims, damages, losses, liabilities, and expenses arising out of:

• Your use of the App
• Your violation of these Terms
• Your violation of any third-party rights
• Any content you submit to the App
''',
            ),
            _buildSection(
              context,
              title: '13. Modifications to Terms',
              content: '''
We reserve the right to modify these Terms at any time. We will notify users of material changes by posting the updated Terms in the App and updating the "Last updated" date.

Your continued use of Karriova after changes constitutes acceptance of the modified Terms.
''',
            ),
            _buildSection(
              context,
              title: '14. Termination',
              content: '''
We may terminate or suspend your account and access to Karriova immediately, without prior notice, for any reason, including breach of these Terms.

Upon termination, your right to use the App will cease immediately. You may request a copy of your data before account deletion as provided in the App settings.
''',
            ),
            _buildSection(
              context,
              title: '15. Governing Law',
              content: '''
These Terms shall be governed by and construed in accordance with applicable laws, without regard to conflict of law principles.

Any disputes arising from these Terms or your use of Karriova shall be resolved through binding arbitration, except where prohibited by law.
''',
            ),
            _buildSection(
              context,
              title: '16. Contact Us',
              content: '''
If you have any questions about these Terms, please contact us at:

Email: legal@karriova.com
Address: Karriova Inc.

We aim to respond to all inquiries within 5 business days.
''',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using Karriova, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
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
}
