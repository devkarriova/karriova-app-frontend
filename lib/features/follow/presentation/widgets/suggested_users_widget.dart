import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/follow_model.dart';
import '../bloc/follow_bloc.dart';
import '../bloc/follow_event.dart';
import '../bloc/follow_state.dart';
import 'follow_button.dart';

class SuggestedUsersCard extends StatelessWidget {
  final VoidCallback? onUserTap;

  const SuggestedUsersCard({
    super.key,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        if (state.suggestedUsers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'People you may know',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<FollowBloc>().add(const LoadSuggestedUsersEvent(refresh: true));
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...state.suggestedUsers.map((user) => _SuggestedUserTile(
                      user: user,
                      onTap: onUserTap,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuggestedUserTile extends StatelessWidget {
  final FollowUserModel user;
  final VoidCallback? onTap;

  const _SuggestedUserTile({
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user.photoUrl == null || user.photoUrl!.isEmpty
            ? Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: user.headline != null
          ? Text(
              user.headline!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            )
          : null,
      trailing: FollowButton(
        userId: user.id,
        initialIsFollowing: user.isFollowing,
      ),
      onTap: onTap,
    );
  }
}

class SuggestedUsersHorizontalList extends StatelessWidget {
  final Function(String userId)? onUserTap;

  const SuggestedUsersHorizontalList({
    super.key,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        if (state.suggestedUsers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'People you may know',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<FollowBloc>().add(const LoadSuggestedUsersEvent(refresh: true));
                    },
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: state.suggestedUsers.length,
                itemBuilder: (context, index) {
                  final user = state.suggestedUsers[index];
                  return _SuggestedUserCard(
                    user: user,
                    onTap: () => onUserTap?.call(user.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestedUserCard extends StatelessWidget {
  final FollowUserModel user;
  final VoidCallback? onTap;

  const _SuggestedUserCard({
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (user.headline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.headline!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(),
                FollowButton(
                  userId: user.id,
                  initialIsFollowing: user.isFollowing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
