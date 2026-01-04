import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../follow/presentation/bloc/follow_bloc.dart';
import '../../../follow/presentation/bloc/follow_event.dart';
import '../../../follow/presentation/bloc/follow_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_banner.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_tabs.dart';
import '../widgets/edit_forms/personal_details_dialog.dart';

/// Profile page - Enterprise-level implementation with BLoC pattern
class ProfilePage extends StatefulWidget {
  final String? userId; // null means current user's profile

  const ProfilePage({
    super.key,
    this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileBloc _profileBloc;
  late FollowBloc _followBloc;
  bool _profileLoaded = false;

  bool get isOwnProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    _profileBloc = getIt<ProfileBloc>();
    _followBloc = getIt<FollowBloc>();

    // Load profile after first frame if already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authBloc = context.read<AuthBloc>();
      if (authBloc.state.status == AuthStatus.authenticated) {
        _loadProfile();
      }
    });
  }

  void _loadProfile() {
    if (_profileLoaded) return;
    _profileLoaded = true;

    if (isOwnProfile) {
      _profileBloc.add(const ProfileLoadMyProfileRequested());
    } else {
      _profileBloc.add(ProfileLoadRequested(userId: widget.userId!));
      // Load follow status for the user being viewed
      _followBloc.add(LoadFollowStatusEvent(widget.userId!));
    }

    // Ensure followingIds are loaded for the follow button state
    if (_followBloc.state.followingIds.isEmpty &&
        _followBloc.state.status != FollowStatus.loading) {
      _followBloc.add(const LoadFollowingIdsEvent());
    }
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileBloc),
        // FollowBloc is now a singleton - use value instead of create
        BlocProvider.value(value: _followBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          // Load profile when auth becomes ready
          if (authState.status == AuthStatus.authenticated && !_profileLoaded) {
            _loadProfile();
          }
        },
        child: const _ProfilePageContent(),
      ),
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

                // Get current user from AuthBloc to determine if this is own profile
                final currentUser = context.read<AuthBloc>().state.user;
                final isOwnProfile =
                    currentUser != null && profile.userId == currentUser.id;

                // Use profile data for display (works for both own and other profiles)
                final userName = profile.name.isNotEmpty
                    ? profile.name
                    : (profile.email.isNotEmpty ? profile.email : 'User');
                final userInitials = profile.initials;

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ProfileBloc>()
                        .add(const ProfileRefreshRequested());
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
                          name: userName,
                          userId: profile.userId,
                          isPremium: true,
                          title: profile.experience.isNotEmpty
                              ? '${profile.experience.first.title} at ${profile.experience.first.company}'
                              : (profile.headline.isNotEmpty
                                  ? profile.headline
                                  : 'Add your professional headline'),
                          institution: profile.education.isNotEmpty
                              ? profile.education.first.institution
                              : 'No education added',
                          location: profile.experience.isNotEmpty
                              ? profile.experience.first.location
                              : (profile.location.isNotEmpty
                                  ? profile.location
                                  : 'Add location'),
                          isOwnProfile: isOwnProfile,
                          onEditProfile: isOwnProfile
                              ? () async {
                                  final user =
                                      context.read<AuthBloc>().state.user;
                                  if (user == null) return;
                                  final result =
                                      await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (context) => PersonalDetailsDialog(
                                      initialName: userName,
                                      initialEmail: user.email,
                                      initialHeadline: profile.headline,
                                      initialWebsite: profile.website,
                                      initialIsPublic:
                                          true, // TODO: Get from profile settings
                                    ),
                                  );
                                  if (result != null && context.mounted) {
                                    context.read<ProfileBloc>().add(
                                          ProfilePersonalDetailsUpdated(
                                            name: result['name'] as String?,
                                            email: result['email'] as String?,
                                            headline:
                                                result['headline'] as String?,
                                            website:
                                                result['website'] as String?,
                                            isPublic:
                                                result['isPublic'] as bool?,
                                          ),
                                        );
                                  }
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
}
