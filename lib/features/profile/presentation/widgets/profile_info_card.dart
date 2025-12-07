import 'package:flutter/material.dart';

/// Profile info card widget - displays user info and action buttons
class ProfileInfoCard extends StatelessWidget {
  final String name;
  final bool isPremium;
  final String title;
  final String institution;
  final String location;
  final bool isOwnProfile;
  final VoidCallback? onConnect;
  final VoidCallback? onSendMessage;
  final VoidCallback? onEditProfile;

  const ProfileInfoCard({
    super.key,
    required this.name,
    this.isPremium = false,
    required this.title,
    required this.institution,
    required this.location,
    this.isOwnProfile = false,
    this.onConnect,
    this.onSendMessage,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 72, 16, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Edit Profile Button (for own profile - top right)
              if (isOwnProfile && onEditProfile != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: onEditProfile,
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Title/Bio
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 16),

          // Institution
          Row(
            children: [
              Icon(Icons.school, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  institution,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          // Action buttons for other users
          if (!isOwnProfile) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                if (onConnect != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B9D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Connect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (onConnect != null && onSendMessage != null)
                  const SizedBox(width: 12),
                if (onSendMessage != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSendMessage,
                      icon: const Icon(Icons.mail_outline, size: 20),
                      label: const Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
