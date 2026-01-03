import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/follow_bloc.dart';
import '../bloc/follow_event.dart';
import '../bloc/follow_state.dart';

class FollowButton extends StatelessWidget {
  final String userId;
  final bool? initialIsFollowing;
  final VoidCallback? onFollowChanged;

  const FollowButton({
    super.key,
    required this.userId,
    this.initialIsFollowing,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        final isFollowing = state.isFollowing(userId) || (initialIsFollowing ?? false);

        return OutlinedButton(
          onPressed: () {
            if (isFollowing) {
              context.read<FollowBloc>().add(UnfollowUserEvent(userId));
            } else {
              context.read<FollowBloc>().add(FollowUserEvent(userId));
            }
            onFollowChanged?.call();
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.transparent : Theme.of(context).primaryColor,
            foregroundColor: isFollowing ? Theme.of(context).primaryColor : Colors.white,
            side: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }
}

class FollowIconButton extends StatelessWidget {
  final String userId;
  final bool? initialIsFollowing;
  final VoidCallback? onFollowChanged;

  const FollowIconButton({
    super.key,
    required this.userId,
    this.initialIsFollowing,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        final isFollowing = state.isFollowing(userId) || (initialIsFollowing ?? false);

        return IconButton(
          onPressed: () {
            if (isFollowing) {
              context.read<FollowBloc>().add(UnfollowUserEvent(userId));
            } else {
              context.read<FollowBloc>().add(FollowUserEvent(userId));
            }
            onFollowChanged?.call();
          },
          icon: Icon(
            isFollowing ? Icons.person_remove : Icons.person_add,
            color: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
          ),
          tooltip: isFollowing ? 'Unfollow' : 'Follow',
        );
      },
    );
  }
}
