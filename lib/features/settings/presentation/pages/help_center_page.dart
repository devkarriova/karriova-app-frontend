import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<_FAQCategory> _categories = [
    _FAQCategory(
      title: 'Getting Started',
      icon: Icons.rocket_launch_outlined,
      faqs: [
        _FAQ(
          question: 'How do I create an account?',
          answer: 'To create an account:\n\n'
              '1. Download the Karriova app or visit our website\n'
              '2. Tap "Sign Up" on the login screen\n'
              '3. Enter your email address and create a password\n'
              '4. Verify your email address\n'
              '5. Complete your profile with your education and career interests\n\n'
              'You can also sign up using your Google account for faster registration.',
        ),
        _FAQ(
          question: 'How do I complete my profile?',
          answer: 'A complete profile helps you connect with mentors and peers:\n\n'
              '1. Go to your Profile page\n'
              '2. Add a profile photo\n'
              '3. Write a headline about your career aspirations\n'
              '4. Add your education details and interests\n'
              '5. List skills you have or want to develop\n'
              '6. Include your location and contact preferences\n\n'
              'Tip: Profiles with photos get 21x more engagement!',
        ),
        _FAQ(
          question: 'What is a KIT Score?',
          answer: 'Your KIT Score measures your engagement and growth on Karriova. '
              'A higher score increases your visibility to mentors and peers, and helps track your professional development.\n\n'
              'Ways to improve your KIT Score:\n'
              '• Complete all profile sections\n'
              '• Add skills and get endorsements\n'
              '• Take skill assessments\n'
              '• Engage with posts and connections\n'
              '• Complete learning path milestones\n'
              '• Keep your profile updated',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Career Roadmap',
      icon: Icons.route_outlined,
      faqs: [
        _FAQ(
          question: 'What is a Career Roadmap?',
          answer: 'Your Career Roadmap is a personalized guide to help you navigate your career journey while still in education.\n\n'
              'It includes:\n'
              '• Skill assessments to identify your strengths\n'
              '• Recommended learning paths based on your interests\n'
              '• Milestone tracking for your professional development\n'
              '• Industry insights and career exploration tools\n'
              '• Connections with mentors and professionals in your field of interest',
        ),
        _FAQ(
          question: 'How do I create my Career Roadmap?',
          answer: 'To set up your personalized roadmap:\n\n'
              '1. Complete your profile with your education details\n'
              '2. Take the career interest assessment\n'
              '3. Select industries or roles you\'re curious about\n'
              '4. Set your short-term and long-term goals\n'
              '5. Karriova will generate a customized roadmap with actionable steps\n\n'
              'You can update your goals anytime as your interests evolve!',
        ),
        _FAQ(
          question: 'What are Skill Assessments?',
          answer: 'Skill Assessments help you understand your current abilities and identify areas for growth.\n\n'
              'Benefits:\n'
              '• Get a clear picture of your strengths\n'
              '• Identify skill gaps for your desired career\n'
              '• Earn badges to showcase on your profile\n'
              '• Receive personalized learning recommendations\n'
              '• Track your progress over time\n\n'
              'Assessments cover both technical skills and soft skills like communication and leadership.',
        ),
        _FAQ(
          question: 'How do I find a mentor?',
          answer: 'Mentorship is key to career development:\n\n'
              '1. Browse professionals in your field of interest\n'
              '2. Look for the "Open to Mentoring" badge on profiles\n'
              '3. Send a personalized connection request explaining your goals\n'
              '4. Be specific about what guidance you\'re seeking\n\n'
              'Tips for a great mentorship:\n'
              '• Come prepared with questions\n'
              '• Respect their time\n'
              '• Follow up on their advice\n'
              '• Share your progress and wins',
        ),
        _FAQ(
          question: 'How can I explore different career paths?',
          answer: 'Karriova helps you explore careers before committing:\n\n'
              '• Industry Insights: Learn about different sectors\n'
              '• Day-in-the-Life: See what professionals actually do\n'
              '• Required Skills: Understand what you need to learn\n'
              '• Growth Outlook: See industry trends and opportunities\n'
              '• Connect with Professionals: Ask questions directly\n\n'
              'Use the Explore tab to discover careers that match your interests and values.',
        ),
        _FAQ(
          question: 'What are Learning Paths?',
          answer: 'Learning Paths are curated sequences of skills and knowledge to help you reach your career goals.\n\n'
              'Each path includes:\n'
              '• Step-by-step skill milestones\n'
              '• Recommended courses and resources\n'
              '• Projects to build your portfolio\n'
              '• Community challenges\n'
              '• Progress tracking\n\n'
              'Paths are designed for students and can be completed alongside your education.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Connections & Networking',
      icon: Icons.people_outline,
      faqs: [
        _FAQ(
          question: 'How do I connect with someone?',
          answer: 'To send a connection request:\n\n'
              '1. Visit the person\'s profile\n'
              '2. Tap the "Connect" button\n'
              '3. Optionally add a personalized note (recommended)\n'
              '4. Tap "Send"\n\n'
              'The person will receive your request and can accept or decline. '
              'Once connected, you can message each other directly.',
        ),
        _FAQ(
          question: 'What\'s the difference between Follow and Connect?',
          answer: 'Follow: One-way relationship\n'
              '• See their posts in your feed\n'
              '• No approval needed\n'
              '• Cannot message directly\n\n'
              'Connect: Two-way relationship\n'
              '• Both parties must agree\n'
              '• See each other\'s posts\n'
              '• Can message directly\n'
              '• Appears in each other\'s network',
        ),
        _FAQ(
          question: 'How do I manage connection requests?',
          answer: 'To manage pending requests:\n\n'
              '1. Go to your Network tab\n'
              '2. Tap "Invitations" or "Pending"\n'
              '3. Review each request\n'
              '4. Tap "Accept" or "Ignore"\n\n'
              'Tip: Check the person\'s profile before accepting to ensure they\'re relevant to your network.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Messaging',
      icon: Icons.chat_bubble_outline,
      faqs: [
        _FAQ(
          question: 'How do I send a message?',
          answer: 'To message someone:\n\n'
              '1. Go to the Messages tab\n'
              '2. Tap the compose icon (+)\n'
              '3. Search for a connection by name\n'
              '4. Type your message\n'
              '5. Tap Send\n\n'
              'You can only message people you\'re connected with, unless they\'ve enabled "Open to Messages" in their privacy settings.',
        ),
        _FAQ(
          question: 'Can I delete messages?',
          answer: 'Yes, you can delete messages:\n\n'
              '1. Open the conversation\n'
              '2. Long-press on the message you want to delete\n'
              '3. Tap "Delete"\n'
              '4. Choose "Delete for me" or "Delete for everyone"\n\n'
              'Note: "Delete for everyone" only works within 1 hour of sending.',
        ),
        _FAQ(
          question: 'How do I block someone?',
          answer: 'To block a user:\n\n'
              '1. Go to their profile\n'
              '2. Tap the three-dot menu\n'
              '3. Select "Block"\n'
              '4. Confirm your choice\n\n'
              'Blocked users cannot:\n'
              '• View your profile\n'
              '• Send you messages\n'
              '• See your posts\n'
              '• Send connection requests\n\n'
              'You can unblock users from Settings > Privacy > Blocked Users.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Account & Security',
      icon: Icons.security_outlined,
      faqs: [
        _FAQ(
          question: 'How do I change my password?',
          answer: 'To change your password:\n\n'
              '1. Go to Settings > Security\n'
              '2. Tap "Change Password"\n'
              '3. Enter your current password\n'
              '4. Enter and confirm your new password\n'
              '5. Tap "Save"\n\n'
              'Your new password must be at least 8 characters and include a mix of letters, numbers, and symbols.',
        ),
        _FAQ(
          question: 'How do I enable two-factor authentication?',
          answer: 'To enable 2FA for extra security:\n\n'
              '1. Go to Settings > Security\n'
              '2. Tap "Two-Factor Authentication"\n'
              '3. Choose your method: SMS or Authenticator App\n'
              '4. Follow the setup instructions\n'
              '5. Save your backup codes\n\n'
              'We strongly recommend enabling 2FA to protect your account.',
        ),
        _FAQ(
          question: 'How do I download my data?',
          answer: 'Under GDPR, you have the right to download your data:\n\n'
              '1. Go to Settings > Privacy\n'
              '2. Tap "Download My Data"\n'
              '3. Your data will be compiled and downloaded as a JSON file\n\n'
              'The export includes your profile, posts, messages, connections, and activity history.',
        ),
        _FAQ(
          question: 'How do I delete my account?',
          answer: 'To permanently delete your account:\n\n'
              '1. Go to Settings > Account Settings\n'
              '2. Scroll to "Danger Zone"\n'
              '3. Tap "Delete Account"\n'
              '4. Type "DELETE" to confirm\n'
              '5. Enter your password\n\n'
              '⚠️ This action is permanent and cannot be undone. All your data, connections, and history will be permanently removed.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Privacy',
      icon: Icons.privacy_tip_outlined,
      faqs: [
        _FAQ(
          question: 'Who can see my profile?',
          answer: 'You control your profile visibility:\n\n'
              '• Public: Anyone can view your profile\n'
              '• Connections Only: Only your connections can see your full profile\n'
              '• Private: Only you can see your profile\n\n'
              'Change this in Settings > Privacy > Profile Visibility.',
        ),
        _FAQ(
          question: 'How do I control who can message me?',
          answer: 'To manage messaging permissions:\n\n'
              '1. Go to Settings > Privacy\n'
              '2. Find "Messaging"\n'
              '3. Choose who can message you:\n'
              '   • Anyone\n'
              '   • Connections only\n'
              '   • No one\n\n'
              'You can also block specific users from messaging you.',
        ),
        _FAQ(
          question: 'How is my data protected?',
          answer: 'Karriova takes data protection seriously:\n\n'
              '• All data is encrypted in transit (TLS 1.3)\n'
              '• Passwords are securely hashed\n'
              '• We comply with GDPR and data protection laws\n'
              '• Regular security audits\n'
              '• You can download or delete your data anytime\n\n'
              'Read our full Privacy Policy for more details.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      faqs: [
        _FAQ(
          question: 'How do I manage notifications?',
          answer: 'To customize your notifications:\n\n'
              '1. Go to Settings > Notifications\n'
              '2. Toggle categories on/off:\n'
              '   • Messages\n'
              '   • Connection requests\n'
              '   • Learning path updates\n'
              '   • Post interactions\n'
              '   • Milestone reminders\n'
              '3. Choose delivery method: Push, Email, or Both',
        ),
        _FAQ(
          question: 'Why am I not receiving notifications?',
          answer: 'If you\'re not receiving notifications:\n\n'
              '1. Check that notifications are enabled in the app (Settings > Notifications)\n'
              '2. Check your device settings:\n'
              '   • iOS: Settings > Karriova > Notifications\n'
              '   • Android: Settings > Apps > Karriova > Notifications\n'
              '3. Make sure you\'re not in Do Not Disturb mode\n'
              '4. Check your email spam folder for email notifications\n'
              '5. Try logging out and back in',
        ),
      ],
    ),
  ];

  List<_FAQ> get _filteredFAQs {
    if (_searchQuery.isEmpty) return [];
    
    final query = _searchQuery.toLowerCase();
    final results = <_FAQ>[];
    
    for (final category in _categories) {
      for (final faq in category.faqs) {
        if (faq.question.toLowerCase().contains(query) ||
            faq.answer.toLowerCase().contains(query)) {
          results.add(faq);
        }
      }
    }
    
    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for help...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              
              // Content
              Expanded(
                child: _searchQuery.isNotEmpty
                    ? _buildSearchResults()
                    : _buildCategories(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactSupport(context),
        icon: const Icon(Icons.support_agent),
        label: const Text('Contact Support'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredFAQs;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or browse categories below',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Text('Browse All Topics'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildFAQCard(results[index]);
      },
    );
  }

  Widget _buildCategories() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Quick Actions
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                onTap: () => _showReportBug(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.feedback_outlined,
                title: 'Give Feedback',
                onTap: () => _showFeedback(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // FAQ Categories
        const Text(
          'Browse Topics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._categories.map((category) => _buildCategoryTile(category)),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildCategoryTile(_FAQCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(category.icon, color: AppColors.primary),
        ),
        title: Text(
          category.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${category.faqs.length} articles',
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
        ),
        children: category.faqs.map((faq) => _buildFAQTile(faq)).toList(),
      ),
    );
  }

  Widget _buildFAQTile(_FAQ faq) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(
        faq.question,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => _showFAQDetail(context, faq),
    );
  }

  Widget _buildFAQCard(_FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showFAQDetail(context, faq),
      ),
    );
  }

  void _showFAQDetail(BuildContext context, _FAQ faq) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Builder(
              builder: (context) => Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    faq.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    faq.answer,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Was this helpful?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thanks for your feedback!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.thumb_up_outlined),
                        label: const Text('Yes'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactSupport(context);
                        },
                        icon: const Icon(Icons.thumb_down_outlined),
                        label: const Text('No'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re here to help! Choose how you\'d like to reach us.',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 24),
              _ContactOption(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@karriova.com',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening email client...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _ContactOption(
                icon: Icons.chat_outlined,
                title: 'Live Chat',
                subtitle: 'Available 9am-6pm EST',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Live chat coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportBug(BuildContext context) {
    final descriptionController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report a Bug',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help us fix issues by describing what went wrong.',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe the bug...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bug report submitted. Thank you!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Report'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    final feedbackController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Give Feedback',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'d love to hear your thoughts on how we can improve.',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your feedback...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback submitted. Thank you!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Feedback'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).disabledColor),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQCategory {
  final String title;
  final IconData icon;
  final List<_FAQ> faqs;

  const _FAQCategory({
    required this.title,
    required this.icon,
    required this.faqs,
  });
}

class _FAQ {
  final String question;
  final String answer;

  const _FAQ({
    required this.question,
    required this.answer,
  });
}
