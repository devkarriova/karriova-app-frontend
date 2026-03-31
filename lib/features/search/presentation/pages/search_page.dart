import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../follow/presentation/bloc/follow_bloc.dart';
import '../../../follow/presentation/bloc/follow_event.dart';
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

  // Filter state
  String? _schoolNameFilter;
  String? _classGradeFilter;
  String? _streamFilter;
  String? _locationFilter;
  List<String> _interestsFilter = [];

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
    context.read<SearchBloc>().add(SearchQueryChanged(
      query: value,
      schoolName: _schoolNameFilter,
      classGrade: _classGradeFilter,
      stream: _streamFilter,
      location: _locationFilter,
      interests: _interestsFilter.isEmpty ? null : _interestsFilter,
    ));
  }

  void _onClearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  void _onClearFilters() {
    setState(() {
      _schoolNameFilter = null;
      _classGradeFilter = null;
      _streamFilter = null;
      _locationFilter = null;
      _interestsFilter = [];
    });
    // Re-trigger search with cleared filters
    if (_searchController.text.isNotEmpty) {
      _onSearchChanged(_searchController.text);
    }
  }

  bool get _hasActiveFilters {
    return _schoolNameFilter != null ||
        _classGradeFilter != null ||
        _streamFilter != null ||
        _locationFilter != null ||
        _interestsFilter.isNotEmpty;
  }

  void _showFilterDialog() {
    final schoolController = TextEditingController(text: _schoolNameFilter ?? '');
    final locationController = TextEditingController(text: _locationFilter ?? '');
    final interestsController = TextEditingController(text: _interestsFilter.join(', '));
    String? selectedClass = _classGradeFilter;
    String? selectedStream = _streamFilter;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Search'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: schoolController,
                  decoration: const InputDecoration(
                    labelText: 'School/College Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Class/Grade',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.class_),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Any')),
                    DropdownMenuItem(value: '9', child: Text('Class 9')),
                    DropdownMenuItem(value: '10', child: Text('Class 10')),
                    DropdownMenuItem(value: '11', child: Text('Class 11')),
                    DropdownMenuItem(value: '12', child: Text('Class 12')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedClass = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStream,
                  decoration: const InputDecoration(
                    labelText: 'Stream',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Any')),
                    DropdownMenuItem(value: 'Science', child: Text('Science')),
                    DropdownMenuItem(value: 'Commerce', child: Text('Commerce')),
                    DropdownMenuItem(value: 'Arts', child: Text('Arts')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedStream = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: interestsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Interests (comma separated)',
                    hintText: 'e.g., Reading, Sports, Music',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.interests),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _schoolNameFilter = schoolController.text.trim().isEmpty
                      ? null
                      : schoolController.text.trim();
                  _classGradeFilter = selectedClass;
                  _streamFilter = selectedStream;
                  _locationFilter = locationController.text.trim().isEmpty
                      ? null
                      : locationController.text.trim();
                  _interestsFilter = interestsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                });
                Navigator.pop(dialogContext);
                // Re-trigger search with new filters
                if (_searchController.text.isNotEmpty) {
                  _onSearchChanged(_searchController.text);
                }
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    ).then((_) {
      schoolController.dispose();
      locationController.dispose();
      interestsController.dispose();
    });
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
              child: Column(
                children: [
                  BlocBuilder<SearchBloc, SearchState>(
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
                  const SizedBox(height: 12),
                  // Filter button and active filters
                  Row(
                    children: [
                      Flexible(
                        child: OutlinedButton.icon(
                          onPressed: _showFilterDialog,
                          icon: Icon(
                            Icons.filter_list,
                            size: 18,
                            color: _hasActiveFilters ? AppColors.primary : AppColors.textSecondary,
                          ),
                          label: Text(
                            'Filters',
                            style: TextStyle(
                              color: _hasActiveFilters ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _hasActiveFilters ? AppColors.primary : AppColors.divider,
                            ),
                          ),
                        ),
                      ),
                      if (_hasActiveFilters) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (_schoolNameFilter != null)
                                  _buildFilterChip('School: $_schoolNameFilter'),
                                if (_classGradeFilter != null)
                                  _buildFilterChip('Class: $_classGradeFilter'),
                                if (_streamFilter != null)
                                  _buildFilterChip('Stream: $_streamFilter'),
                                if (_locationFilter != null)
                                  _buildFilterChip('Location: $_locationFilter'),
                                if (_interestsFilter.isNotEmpty)
                                  _buildFilterChip('${_interestsFilter.length} interests'),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear_all, size: 20),
                          onPressed: _onClearFilters,
                          tooltip: 'Clear filters',
                        ),
                      ],
                    ],
                  ),
                ],
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

    // Show skeleton loaders while loading
    if (state.isLoading && state.users.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildUserSkeletonTile(),
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

  Widget _buildUserSkeletonTile() {
    return ShimmerEffect(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SkeletonCircle(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 140, height: 16),
                    const SizedBox(height: 6),
                    const SkeletonBox(width: 100, height: 12),
                    const SizedBox(height: 6),
                    const SkeletonBox(width: 180, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const SkeletonBox(width: 80, height: 32, borderRadius: 20),
            ],
          ),
        ),
      ),
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

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
