import 'package:flutter/material.dart';
import 'package:karriova_app/core/constants/app_colors.dart';

/// Profile info widget - displays detailed user information in a card format
/// This widget shows contact info, social links, and other profile details
class ProfileInfo extends StatelessWidget {
  final String? email;
  final String? phone;
  final String? website;
  final String? linkedInUrl;
  final String? twitterUrl;
  final String? location;
  final DateTime? memberSince;
  final bool showEmail;
  final bool showPhone;

  const ProfileInfo({
    super.key,
    this.email,
    this.phone,
    this.website,
    this.linkedInUrl,
    this.twitterUrl,
    this.location,
    this.memberSince,
    this.showEmail = true,
    this.showPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (location != null && location!.isNotEmpty) {
      items.add(_buildInfoItem(
        context,
        icon: Icons.location_on_outlined,
        label: 'Location',
        value: location!,
      ));
    }

    if (showEmail && email != null && email!.isNotEmpty) {
      items.add(_buildInfoItem(
        context,
        icon: Icons.email_outlined,
        label: 'Email',
        value: email!,
        isLink: true,
      ));
    }

    if (showPhone && phone != null && phone!.isNotEmpty) {
      items.add(_buildInfoItem(
        context,
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: phone!,
        isLink: true,
      ));
    }

    if (website != null && website!.isNotEmpty) {
      items.add(_buildInfoItem(
        context,
        icon: Icons.language_outlined,
        label: 'Website',
        value: website!,
        isLink: true,
      ));
    }

    if (memberSince != null) {
      items.add(_buildInfoItem(
        context,
        icon: Icons.calendar_today_outlined,
        label: 'Member since',
        value: _formatDate(memberSince!),
      ));
    }

    // Social links
    final socialLinks = <Widget>[];
    if (linkedInUrl != null && linkedInUrl!.isNotEmpty) {
      socialLinks.add(_buildSocialButton(
        context,
        icon: Icons.work_outline,
        label: 'LinkedIn',
        url: linkedInUrl!,
        color: const Color(0xFF0077B5),
      ));
    }
    if (twitterUrl != null && twitterUrl!.isNotEmpty) {
      socialLinks.add(_buildSocialButton(
        context,
        icon: Icons.alternate_email,
        label: 'Twitter',
        url: twitterUrl!,
        color: const Color(0xFF1DA1F2),
      ));
    }

    if (items.isEmpty && socialLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...items.expand((item) => [item, const SizedBox(height: 12)]).take(items.length * 2 - 1),
            if (socialLinks.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Social Links',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: socialLinks,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isLink ? AppColors.primary : Colors.grey[800],
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Launch URL
      },
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
