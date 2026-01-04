import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../follow/presentation/bloc/follow_bloc.dart';
import '../../../follow/presentation/bloc/follow_event.dart';
import '../../../follow/presentation/bloc/follow_state.dart';
import '../../../follow/presentation/widgets/follow_button.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

/// Minimalist search page for users and posts with BLoC integration
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get query parameter from URL
    final query = GoRouterState.of(context).uri.queryParameters['q'];

    // Get singleton FollowBloc and always refresh followingIds to ensure correct state
    final followBloc = getIt<FollowBloc>();
    // Always load fresh followingIds when entering search page
    followBloc.add(const LoadFollowingIdsEvent());

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<SearchBloc>()),
        BlocProvider.value(value: followBloc),
      ],
      child: _SearchPageContent(initialQuery: query),
    );
  }
}

class _SearchPageContent extends StatefulWidget {
  final String? initialQuery;

  const _SearchPageContent({this.initialQuery});

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set initial query from URL parameter if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      // Trigger search with initial query
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<SearchBloc>()
              .add(SearchQueryChanged(query: widget.initialQuery!));
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<SearchBloc>().add(SearchQueryChanged(query: value));
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  return TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search for people...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      prefixIcon: state.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : const Icon(Icons.search,
                              color: AppColors.textSecondary),
                      suffixIcon: state.query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: _onClearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Results
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? 'An error occurred',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildPeopleResults(state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleResults(SearchState state) {
    if (state.query.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'Search for people',
        subtitle: 'Find professionals by name or headline',
      );
    }

    if (state.users.isEmpty && state.status == SearchStatus.success) {
      return _buildEmptyState(
        icon: Icons.person_search,
        title: 'No people found',
        subtitle: 'Try a different search term',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildUserTile(user: state.users[index]);
      },
    );
  }

  Widget _buildUserTile({required user}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          // Navigate to user profile
          context.push('/profile/${user.id}');
        },
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.surfaceVariant,
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '@${user.username}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (user.headline != null && user.headline!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.headline!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: FollowButton(userId: user.id),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
