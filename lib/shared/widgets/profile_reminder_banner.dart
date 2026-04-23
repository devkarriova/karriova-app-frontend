import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_event.dart';
import '../../features/profile/presentation/bloc/profile_state.dart';

/// Floating bottom-right banner reminding users to complete their profile.
/// Must be placed inside a [Stack] — it uses [Positioned] internally.
class ProfileReminderBanner extends StatefulWidget {
  const ProfileReminderBanner({super.key});

  @override
  State<ProfileReminderBanner> createState() => _ProfileReminderBannerState();
}

class _ProfileReminderBannerState extends State<ProfileReminderBanner> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    // Load profile if not already loaded
    final profileBloc = context.read<ProfileBloc>();
    if (profileBloc.state.profile == null &&
        profileBloc.state.status != ProfileStatus.loading) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user != null) {
        profileBloc.add(ProfileLoadRequested(userId: authState.user!.id));
      }
    }
  }

  bool _isIncomplete(ProfileState state) {
    final p = state.profile;
    if (p == null) return false; // still loading — don't flash the banner
    return p.headline.isEmpty || p.schoolName.isEmpty || p.stream.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.user == null) return const SizedBox.shrink();
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (!_isIncomplete(profileState)) return const SizedBox.shrink();

            return Positioned(
              right: 16,
              bottom: 80,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Colors.black26,
                child: InkWell(
                  onTap: () => context.push(AppRouter.profile),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Complete your profile',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _dismissed = true),
                          child: const Icon(Icons.close_rounded,
                              size: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
