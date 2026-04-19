import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'landing_page.dart';

class LandingAboutPage extends StatelessWidget {
  const LandingAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LandingNavbar(currentRoute: '/about'),
            _MissionSection(),
            _WhatWeDoSection(),
            _TestimonialSection(),
            _CtaSection(),
            const LandingFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── Mission ──────────────────────────────────────────────────────────────────

class _MissionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 120 : 24, vertical: isWide ? 96 : 64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF5EE), Color(0xFFF5F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'About Karriova',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Knowing you matters more\nthan talking about us.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your strengths, dreams, and next step come first.\nWe built Karriova because too many students choose careers based on pressure — not potential.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: AppColors.textSecondary,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── What We Do ───────────────────────────────────────────────────────────────

class _WhatWeDoSection extends StatelessWidget {
  static const _items = [
    _AboutItem(
      icon: Icons.psychology_outlined,
      color: AppColors.primary,
      title: 'Psychometric Intelligence',
      body: 'The KIT Assessment maps your personality, aptitude, RIASEC profile, and orientation — giving you a complete picture of where you naturally excel.',
    ),
    _AboutItem(
      icon: Icons.map_outlined,
      color: AppColors.secondary,
      title: 'Personalised Roadmaps',
      body: 'AI turns your scores into a 14-section Career Blueprint — your step-by-step path from where you are to where you want to be.',
    ),
    _AboutItem(
      icon: Icons.people_outline,
      color: Colors.teal,
      title: 'Expert Mentorship',
      body: 'Connect with verified mentors who have walked the path you\'re considering. Real guidance from real experience.',
    ),
    _AboutItem(
      icon: Icons.public_outlined,
      color: AppColors.info,
      title: 'Built for India',
      body: 'Matched against 61 curated Indian career profiles with entrance paths, stream guidance, and realistic salary projections.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 72),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'What We Do',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'One platform that turns confusion into clarity.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: _items.map((item) {
              return SizedBox(
                width: isWide ? 280 : double.infinity,
                child: _AboutCard(item: item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AboutItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _AboutItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}

class _AboutCard extends StatelessWidget {
  final _AboutItem item;
  const _AboutCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(item.title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(item.body,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Testimonial ──────────────────────────────────────────────────────────────

class _TestimonialSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 120 : 24, vertical: 72),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF5EE), Color(0xFFF5F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 24),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '"Karriova helped me see my strengths clearly, saving me from choosing the wrong path early on."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Amit',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Early Access User',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── CTA ──────────────────────────────────────────────────────────────────────

class _CtaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 56),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'Your next step starts here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Take the free KIT Assessment and discover careers that actually fit.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/login?mode=signup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Get Started — It\'s Free',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
