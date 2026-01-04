import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../follow/domain/models/follow_model.dart';
import '../../../follow/presentation/bloc/follow_bloc.dart';
import '../../../follow/presentation/bloc/follow_event.dart';
import '../../../follow/presentation/bloc/follow_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/conversation_tile.dart';
import 'chat_conversation_page.dart';

/// Chat list page - displays list of conversations
/// Modern UI with gradient header, search, and engaging empty states
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final ChatBloc _chatBloc;
  late final FollowBloc _followBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = getIt<ChatBloc>();
    _followBloc = getIt<FollowBloc>();

    // Only load conversations if bloc is in initial state
    if (_chatBloc.state.status == ChatStatus.initial) {
      _chatBloc.add(const ChatConversationsRequested());
    }

    // Only load following if bloc hasn't loaded yet
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';
    if (_followBloc.state.status == FollowStatus.initial) {
      _followBloc.add(LoadFollowingEvent(currentUserId, refresh: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chatBloc),
        BlocProvider.value(value: _followBloc),
      ],
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatefulWidget {
  const _ChatListView();

  @override
  State<_ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<_ChatListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(context, innerBoxIsScrolled),
        ],
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.errorMessage!)),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.status == ChatStatus.loading &&
                  state.conversations.isEmpty) {
                return _buildLoadingState();
              }

              if (state.status == ChatStatus.error &&
                  state.conversations.isEmpty) {
                return _buildErrorState(context, state);
              }

              if (state.conversations.isEmpty) {
                return _buildEmptyStateWithSuggestions(context);
              }

              // Filter conversations based on search
              final filteredConversations = _searchQuery.isEmpty
                  ? state.conversations
                  : state.conversations.where((conv) {
                      final userName =
                          _getUserName(conv.otherUserId).toLowerCase();
                      return userName.contains(_searchQuery.toLowerCase());
                    }).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ChatBloc>().add(
                        const ChatConversationsRequested(isRefresh: true),
                      );
                },
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: filteredConversations.isEmpty && _searchQuery.isNotEmpty
                    ? _buildNoSearchResults()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = filteredConversations[index];
                          return ConversationTile(
                            conversation: conversation,
                            otherUserName:
                                _getUserName(conversation.otherUserId),
                            otherUserPhotoUrl:
                                _getUserPhotoUrl(conversation.otherUserId),
                            isOnline: index % 3 ==
                                0, // Demo: some users appear online
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ChatConversationPage(
                                    conversationId: conversation.id,
                                    otherUserId: conversation.otherUserId,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: _isSearching ? 70 : 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.secondary.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      title: _isSearching
          ? _buildSearchField()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    final unreadCount = state.conversations.fold<int>(
                      0,
                      (sum, conv) => sum + conv.unreadCount,
                    );
                    if (unreadCount > 0) {
                      return Text(
                        '$unreadCount unread message${unreadCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearching ? Icons.close : Icons.search_rounded,
              key: ValueKey(_isSearching),
              color: AppColors.textPrimary,
            ),
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading conversations...',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ChatState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Failed to load conversations',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.read<ChatBloc>().add(
                        const ChatConversationsRequested(isRefresh: true),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get user name
  // TODO: In a real app, you would fetch user details from a user repository
  String _getUserName(String userId) {
    // For now, return a placeholder name
    // In production, this should come from a user cache or API
    return 'User $userId';
  }

  // Helper method to get user photo URL
  // TODO: In a real app, you would fetch user details from a user repository
  String? _getUserPhotoUrl(String userId) {
    // For now, return null
    // In production, this should come from a user cache or API
    return null;
  }

  Widget _buildEmptyStateWithSuggestions(BuildContext context) {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, followState) {
        return CustomScrollView(
          slivers: [
            // Header message with illustration
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 50,
                            color: AppColors.primary.withOpacity(0.6),
                          ),
                          Positioned(
                            right: 20,
                            top: 20,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Start a Conversation',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect with people you follow and start\nmeaningful conversations',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Section header with gradient accent
            if (followState.following.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'People you follow',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${followState.following.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // List of followed users with modern cards
            if (followState.following.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = followState.following[index];
                      return _buildUserCard(context, user);
                    },
                    childCount: followState.following.length,
                  ),
                ),
              ),

            // Loading state
            if (followState.status == FollowStatus.loading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),

            // Empty following list with call to action
            if (followState.following.isEmpty &&
                followState.status != FollowStatus.loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 48,
                              color: AppColors.textTertiary.withOpacity(0.6),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Follow people to start conversations',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/search');
                                },
                                icon:
                                    const Icon(Icons.search_rounded, size: 20),
                                label: const Text('Discover People'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, FollowUserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChatConversationPage(
                  conversationId: '',
                  otherUserId: user.id,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildUserAvatar(user),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (user.headline != null &&
                          user.headline!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          user.headline!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ChatConversationPage(
                            conversationId: '',
                            otherUserId: user.id,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Start conversation',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(FollowUserModel user) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.secondary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: user.photoUrl != null && user.photoUrl!.isNotEmpty
          ? CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(user.photoUrl!),
              backgroundColor: AppColors.surfaceVariant,
            )
          : Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }
}
