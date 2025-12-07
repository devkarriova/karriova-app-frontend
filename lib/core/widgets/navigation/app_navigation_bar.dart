import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../routes/app_router.dart';

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
                label: 'Jobs',
                route: '/jobs',
                isActive: currentRoute == '/jobs',
              ),
              _NavItem(
                icon: Icons.event_outlined,
                label: 'Events',
                route: '/events',
                isActive: currentRoute == '/events',
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
              ),
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
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
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
