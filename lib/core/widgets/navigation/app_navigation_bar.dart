import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../routes/app_router.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';

/// Horizontal navigation bar with menu items
/// Displays below the header on main app pages
class AppNavigationBar extends StatelessWidget {
  final String currentRoute;

  const AppNavigationBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState.user?.isAdmin ?? false;

    return Container(
      height: 44,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavItem(
                icon: Icons.people_outline,
                label: 'Community',
                route: AppRouter.feed,
                isActive: currentRoute == AppRouter.feed,
              ),
              _NavItem(
                icon: Icons.work_outline,
                label: 'Internships',
                route: AppRouter.internships,
                isActive: currentRoute == AppRouter.internships,
              ),
              _NavItem(
                icon: Icons.event_outlined,
                label: 'Events',
                route: AppRouter.events,
                isActive: currentRoute == AppRouter.events,
              ),
              _NavItem(
                icon: Icons.timeline_outlined,
                label: 'Career Roadmap',
                route: '/career-roadmap',
                isActive: currentRoute == '/career-roadmap',
              ),
              _NavItem(
                icon: Icons.description_outlined,
                label: 'CV Generator',
                route: '/cv-generator',
                isActive: currentRoute == '/cv-generator',
                isLocked: true,
              ),
              if (isAdmin)
                _NavItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin',
                  route: '/admin',
                  isActive: currentRoute == '/admin',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item widget
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final bool isLocked;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = isLocked
        ? Colors.grey.shade400
        : (isActive ? AppColors.primary : AppColors.textSecondary);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                isActive && !isLocked ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: itemColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  isActive && !isLocked ? FontWeight.w600 : FontWeight.w500,
              color: itemColor,
            ),
          ),
          if (isLocked) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.lock_outline,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ],
      ),
    );

    if (isLocked) {
      return Tooltip(
        message: 'Coming Soon',
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          child: content,
        ),
      );
    }

    return InkWell(
      onTap: () => context.go(route),
      child: content,
    );
  }
}
