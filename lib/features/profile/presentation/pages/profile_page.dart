import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_banner.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_tabs.dart';

/// Profile page - Enterprise-level implementation with BLoC pattern
class ProfilePage extends StatelessWidget {
  final String? userId; // null means current user's profile

  const ProfilePage({
    super.key,
    this.userId,
  });

  bool get isOwnProfile => userId == null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<ProfileBloc>();
        if (isOwnProfile) {
          bloc.add(const ProfileLoadMyProfileRequested());
        } else {
          bloc.add(ProfileLoadRequested(userId: userId!));
        }
        return bloc;
      },
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          AppNavigationBar(currentRoute: AppRouter.profile),
          Expanded(
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading && !state.hasProfile) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.hasError && !state.hasProfile) {
                  return _buildErrorState(context);
                }

                if (!state.hasProfile) {
                  return _buildNoProfileState(context);
                }

                final profile = state.profile!;
                final userInitials = _getInitials(profile.headline);

                // Get current user from AuthBloc to determine if this is own profile
                final currentUser = context.read<AuthBloc>().state.user;
                final isOwnProfile = currentUser != null && profile.userId == currentUser.id;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProfileBloc>().add(const ProfileRefreshRequested());
                    await context.read<ProfileBloc>().stream.firstWhere(
                          (s) => !s.isLoading,
                        );
                  },
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
                              child: ProfileAvatar(
                                initials: userInitials,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Profile Info Card
                      SliverToBoxAdapter(
                        child: ProfileInfoCard(
                          name: profile.headline.split('|').first.trim(),
                          isPremium: true,
                          title: profile.headline,
                          institution: profile.education.isNotEmpty
                              ? profile.education.first.institution
                              : '',
                          location: profile.location,
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
                      // Note: ProfileTabs sections will access profile data from BLoC context
                      const SliverToBoxAdapter(
                        child: ProfileTabs(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            context.read<ProfileBloc>().state.errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<ProfileBloc>().add(
                  const ProfileLoadMyProfileRequested(),
                ),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No profile found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'This user has not set up their profile yet',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getInitials(String headline) {
    if (headline.trim().isEmpty) return '??';

    final words = headline.trim().split(RegExp(r'\s+'));
    final nonEmptyWords = words.where((w) => w.isNotEmpty).toList();

    if (nonEmptyWords.isEmpty) return '??';

    if (nonEmptyWords.length == 1) {
      return nonEmptyWords[0].length >= 2
          ? nonEmptyWords[0].substring(0, 2).toUpperCase()
          : nonEmptyWords[0][0].toUpperCase();
    }

    return '${nonEmptyWords[0][0]}${nonEmptyWords[1][0]}'.toUpperCase();
  }
}
