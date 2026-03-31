import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class AuthLayout extends StatefulWidget {
  final Widget child;

  const AuthLayout({
    super.key,
    required this.child,
  });

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the logo image
    precacheImage(
      const AssetImage('assets/images/branding/karriova_logo_transparent.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // Left side - Branding
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(AppDimensions.paddingXXL * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with text
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/branding/karriova_logo_transparent.png',
                          height: 50,
                          width: 50,
                          fit: BoxFit.contain,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) return child;
                            return AnimatedOpacity(
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 50,
                              width: 50,
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Karriova',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingXXL * 2),
                    const Text(
                      "India's Premier Career Networking Platform for Students &\nEarly Professionals",
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                    _buildFeature(
                      Icons.group_outlined,
                      'Connect with students across IITs, NITs, and top universities',
                      AppColors.gradientStart,
                    ),
                    const SizedBox(height: AppDimensions.paddingLG),
                    _buildFeature(
                      Icons.description_outlined,
                      'AI-powered CV generation and career guidance',
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(height: AppDimensions.paddingLG),
                    _buildFeature(
                      Icons.verified_outlined,
                      'Digital credential locker with verified badges',
                      const Color(0xFF3B82F6),
                    ),
                  ],
                ),
              ),
            ),
            // Right side - Auth Form
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                      vertical: AppDimensions.paddingLG,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMD),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
