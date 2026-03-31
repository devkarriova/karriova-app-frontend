import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';

/// Admin dashboard page with navigation to sub-sections
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminItems = [
      _AdminCardData(
        title: 'Events',
        subtitle: 'Create and manage events for the community',
        icon: Icons.event,
        color: Colors.blue,
        route: AppRouter.adminEvents,
      ),
      _AdminCardData(
        title: 'Assessments',
        subtitle: 'Manage career assessment questions and scoring',
        icon: Icons.psychology,
        color: Colors.purple,
        route: AppRouter.adminAssessments,
      ),
      _AdminCardData(
        title: 'Feedback',
        subtitle: 'Review and respond to user feedback',
        icon: Icons.support_agent,
        color: Colors.green,
        route: AppRouter.adminFeedback,
      ),
      _AdminCardData(
        title: 'Reminders',
        subtitle: 'Manage system notifications and custom reminders',
        icon: Icons.notifications_active,
        color: Colors.teal,
        route: AppRouter.adminReminders,
      ),
      _AdminCardData(
        title: 'Moderation',
        subtitle: 'Review flagged content and manage reports',
        icon: Icons.shield_outlined,
        color: Colors.orange,
        route: AppRouter.adminModeration,
      ),
      _AdminCardData(
        title: 'Analytics',
        subtitle: 'View platform usage and engagement metrics',
        icon: Icons.analytics,
        color: Colors.indigo,
        route: AppRouter.admin, // Placeholder - coming soon
        comingSoon: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const AppNavigationBar(currentRoute: AppRouter.admin),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage events, assessments, feedback, and content moderation',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate number of columns based on available width
                        final cardWidth = 300.0;
                        final spacing = 16.0;
                        int crossAxisCount = (constraints.maxWidth / cardWidth).floor();
                        crossAxisCount = crossAxisCount.clamp(1, 3);
                        
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: adminItems.map((item) {
                            final itemWidth = crossAxisCount == 1
                                ? constraints.maxWidth
                                : (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                            return SizedBox(
                              width: itemWidth,
                              child: _AdminGridCard(data: item),
                            );
                          }).toList(),
                        );
                      },
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
}

class _AdminCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final bool comingSoon;

  const _AdminCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.comingSoon = false,
  });
}

class _AdminGridCard extends StatefulWidget {
  final _AdminCardData data;

  const _AdminGridCard({required this.data});

  @override
  State<_AdminGridCard> createState() => _AdminGridCardState();
}

class _AdminGridCardState extends State<_AdminGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Card(
          color: AppColors.surface,
          elevation: _isHovered ? 8 : 2,
          shadowColor: widget.data.color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _isHovered
                ? BorderSide(color: widget.data.color.withOpacity(0.3), width: 1)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: widget.data.comingSoon ? null : () => context.go(widget.data.route),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: widget.data.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          widget.data.icon,
                          color: widget.data.color,
                          size: 28,
                        ),
                      ),
                      if (widget.data.comingSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Coming Soon',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: _isHovered ? widget.data.color : AppColors.textTertiary,
                          size: 20,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.data.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.data.comingSoon 
                          ? AppColors.textTertiary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.data.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.data.comingSoon 
                          ? AppColors.textTertiary 
                          : AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
