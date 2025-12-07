import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../routes/app_router.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';

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
      title: Row(
        children: [
          const Text(
            'Karriova',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Expanded(child: Center(child: _SearchBar())),
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

/// Search bar widget
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search jobs, events, people...',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
        onSubmitted: (value) {
          // TODO: Implement search functionality
        },
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
class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Open notifications panel
          },
        ),
        // Notification badge
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
            child: const Center(
              child: Text(
                '3',
                style: TextStyle(
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
  }
}

/// Message icon widget - opens chat window when tapped
class _MessageIcon extends StatelessWidget {
  const _MessageIcon();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.message_outlined),
      onPressed: () {
        context.go(AppRouter.chat);
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
      offset: const Offset(0, 50),
      child: const CircleAvatar(
        radius: 18,
        child: Icon(Icons.person),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            contentPadding: EdgeInsets.zero,
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
}
