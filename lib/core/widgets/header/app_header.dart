import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../routes/app_router.dart';
import '../../di/injection.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../../../features/notifications/presentation/bloc/notification_event.dart';
import '../../../../features/notifications/presentation/bloc/notification_state.dart';
import '../../../../features/chat/presentation/bloc/chat_unread_bloc.dart';
import '../../../../features/chat/presentation/bloc/chat_unread_event.dart';
import '../../../../features/chat/presentation/bloc/chat_unread_state.dart';
import 'notification_dropdown.dart';

/// Common app header widget used across all pages
/// Contains: Logo, Search bar, Notifications, Profile menu
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: const _LogoSection(),
      title: const Row(
        children: [
          Text(
            'Karriova',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(child: Center(child: _SearchBar())),
        ],
      ),
      actions: const [
        _NotificationIcon(),
        SizedBox(width: 8),
        _ProfileMenu(),
        SizedBox(width: 8),
        _MessageIcon(),
        SizedBox(width: 16),
      ],
    );
  }
}

/// Search bar widget with inline search
class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearchSubmit() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.go('${AppRouter.search}?q=$query');
      _searchFocusNode.unfocus();
      _searchController.clear();
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: _isSearching
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search jobs, events, people...',
          hintStyle: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textTertiary),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _isSearching = false);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onTap: () => setState(() => _isSearching = true),
        onChanged: (value) {
          if (value.isEmpty && _isSearching) {
            setState(() => _isSearching = false);
          } else if (value.isNotEmpty && !_isSearching) {
            setState(() => _isSearching = true);
          }
        },
        onSubmitted: (_) => _handleSearchSubmit(),
      ),
    );
  }
}

/// Logo section widget
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0, right: 0),
      child: Image.asset(
        'assets/images/branding/karriova_logo_transparent.png',
        height: 40,
        width: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.business, size: 32);
        },
      ),
    );
  }
}

/// Notification icon widget with badge
class _NotificationIcon extends StatefulWidget {
  const _NotificationIcon();

  @override
  State<_NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<_NotificationIcon> {
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = getIt<NotificationBloc>();
    // Only request refresh if bloc is in initial state (first time loading)
    if (_notificationBloc.state.status == NotificationStatus.initial) {
      _notificationBloc.add(const UnreadCountRefreshRequested());
    }
  }

  @override
  void dispose() {
    // Don't close the bloc - it's a singleton shared across the app
    super.dispose();
  }

  void _showNotificationDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 400),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: BlocProvider.value(
            value: _notificationBloc,
            child: const NotificationDropdown(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      bloc: _notificationBloc,
      builder: (context, state) {
        final unreadCount = state.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _showNotificationDropdown(context),
            ),
            // Notification badge
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Message icon widget with badge - opens chat window when tapped
class _MessageIcon extends StatefulWidget {
  const _MessageIcon();

  @override
  State<_MessageIcon> createState() => _MessageIconState();
}

class _MessageIconState extends State<_MessageIcon> {
  late final ChatUnreadBloc _chatUnreadBloc;

  @override
  void initState() {
    super.initState();
    _chatUnreadBloc = getIt<ChatUnreadBloc>();
    // Only request refresh if bloc is in initial state (first time loading)
    if (_chatUnreadBloc.state.status == ChatUnreadStatus.initial) {
      _chatUnreadBloc.add(const ChatUnreadCountRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatUnreadBloc, ChatUnreadState>(
      bloc: _chatUnreadBloc,
      builder: (context, state) {
        final unreadCount = state.unreadCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.message_outlined),
              onPressed: () {
                context.go(AppRouter.chat);
              },
            ),
            // Unread message badge
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Profile menu widget with dropdown
class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person, color: Colors.white, size: 20),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _buildMenuItem(
            icon: Icons.person_outline,
            label: 'Profile',
            color: const Color(0xFF374151),
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _buildMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            color: const Color(0xFF374151),
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem(
          value: 'logout',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: _buildMenuItem(
            icon: Icons.logout_outlined,
            label: 'Logout',
            color: const Color(0xFFDC2626),
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            context.go(AppRouter.profile);
            break;
          case 'settings':
            // TODO: Navigate to settings page when created
            break;
          case 'logout':
            context.read<AuthBloc>().add(const AuthLogoutRequested());
            context.go(AppRouter.auth);
            break;
        }
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
