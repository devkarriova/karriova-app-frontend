import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../follow/presentation/widgets/follow_button.dart';

/// Profile info card widget - displays user info and action buttons
class ProfileInfoCard extends StatelessWidget {
  final String name;
  final String? userId; // User ID for follow/message actions
  final bool isPremium;
  final String title;
  final String bio;
  final String institution;
  final String location;
  final bool isOwnProfile;
  final VoidCallback? onEditProfile;

  const ProfileInfoCard({
    super.key,
    required this.name,
    this.userId,
    this.isPremium = false,
    required this.title,
    this.bio = '',
    required this.institution,
    required this.location,
    this.isOwnProfile = false,
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

          // Title/Headline
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),

          // Bio (if available)
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              bio,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

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
          if (!isOwnProfile && userId != null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                // Follow/Connect Button
                SizedBox(
                  width: 120,
                  child: FollowButton(userId: userId!),
                ),
                const SizedBox(width: 12),
                // Message Button
                SizedBox(
                  width: 140,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to chat with this user
                      context.push('/chat?userId=$userId&userName=$name');
                    },
                    icon: const Icon(Icons.mail_outline, size: 18),
                    label: const Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
