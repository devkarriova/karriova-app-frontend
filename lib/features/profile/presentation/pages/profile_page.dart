import 'package:flutter/material.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../widgets/profile_banner.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_tabs.dart';

/// Profile page - displays user profile with banner, avatar, and info
class ProfilePage extends StatelessWidget {
  final String? userId; // null means current user's profile

  const ProfilePage({
    super.key,
    this.userId,
  });

  bool get isOwnProfile => userId == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          AppNavigationBar(currentRoute: AppRouter.profile),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Profile Banner and Avatar
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Banner Image
                      const ProfileBanner(),

                      // Avatar positioned overlapping banner and card
                      Positioned(
                        left: 32,
                        bottom: -60,
                        child: const ProfileAvatar(
                          initials: 'PS',
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Info Card
                SliverToBoxAdapter(
                  child: ProfileInfoCard(
                    name: 'Priya Sharma',
                    isPremium: true,
                    title: 'B.Tech Computer Science Student | AI/ML Enthusiast',
                    institution: 'IIT Bombay',
                    location: 'Mumbai, Maharashtra 400001',
                    isOwnProfile: isOwnProfile,
                    onConnect: isOwnProfile
                        ? null
                        : () {
                            // TODO: Handle connect action
                          },
                    onSendMessage: isOwnProfile
                        ? null
                        : () {
                            // TODO: Handle send message action
                          },
                    onEditProfile: isOwnProfile
                        ? () {
                            // TODO: Navigate to edit profile
                          }
                        : null,
                  ),
                ),

                // Profile Tabs (About, Education, Experience, Skills, Achievements)
                const SliverToBoxAdapter(
                  child: ProfileTabs(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
