import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

const _kLinkedIn = 'https://www.linkedin.com/company/karriova/';
const _kInstagram = 'https://www.instagram.com/karriova/';
const _kEmail = 'info@karriova.com';

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Landing Page
// ─────────────────────────────────────────────────────────────────────────────

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LandingNavbar(currentRoute: '/'),
            _Hero(isWide: isWide),
            _Features(),
            _HowItWorks(),
            _CTA(),
            const LandingFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── Navbar (public — reused by FAQ page) ────────────────────────────────────

class LandingNavbar extends StatelessWidget {
  final String currentRoute;
  const LandingNavbar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => context.go('/'),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ).createShader(bounds),
              child: const Text(
                'Karriova',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const Spacer(),
          if (isWide) ...[
            _NavLink(
              label: 'About',
              active: currentRoute == '/about',
              onTap: () => context.go('/about'),
            ),
            const SizedBox(width: 4),
            _NavLink(
              label: 'FAQ',
              active: currentRoute == '/faq',
              onTap: () => context.go('/faq'),
            ),
            const SizedBox(width: 4),
            _NavLink(
              label: 'Contact',
              active: false,
              onTap: () => _openUrl('mailto:$_kEmail'),
            ),
            const SizedBox(width: 16),
          ],
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sign In',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.go('/login?mode=signup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: active ? AppColors.primary : AppColors.textSecondary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
          if (active)
            Container(
              height: 2,
              width: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final bool isWide;
  const _Hero({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 96 : 64,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF5EE), Color(0xFFF5F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(flex: 3, child: _HeroText()),
                const SizedBox(width: 48),
                Expanded(flex: 2, child: _HeroIllustration()),
              ],
            )
          : Column(
              children: [
                _HeroText(),
                const SizedBox(height: 40),
                _HeroIllustration(),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'KIT-Based Career Discovery',
            style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Find Your Career,\nNot Just a Job',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.15,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Karriova uses the scientifically validated KIT assessment to match you to careers that fit your personality, aptitude, and interests — then builds you a personalised roadmap to get there.',
          style: TextStyle(
            fontSize: 17,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/login?mode=signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Take the Assessment — Free',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            OutlinedButton(
              onPressed: () => GoRouter.of(context).go('/careers'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Browse Careers',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 40, spreadRadius: 0),
        ],
      ),
      child: Column(
        children: [
          _ScoreRow('Investigative', 0.82, AppColors.info),
          const SizedBox(height: 12),
          _ScoreRow('Technical Aptitude', 0.74, AppColors.secondary),
          const SizedBox(height: 12),
          _ScoreRow('Realistic', 0.68, AppColors.primary),
          const SizedBox(height: 12),
          _ScoreRow('Logical Reasoning', 0.61, Colors.teal),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text('Top Match', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 4),
                Text('Software Engineer',
                    style: TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('92% Fit Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ScoreRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text('${(value * 100).toInt()}',
                style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Features ─────────────────────────────────────────────────────────────────

class _Features extends StatelessWidget {
  static const _items = [
    _FeatureItem(
      icon: Icons.psychology_outlined,
      color: AppColors.primary,
      title: 'KIT Assessment',
      body: '120 questions across Personality, RIASEC, Aptitude, and Orientation — matched against 61 real career profiles.',
    ),
    _FeatureItem(
      icon: Icons.map_outlined,
      color: AppColors.secondary,
      title: 'Career Blueprint',
      body: 'AI-generated 14-section roadmap for your top career matches — from skill gaps to salary projections.',
    ),
    _FeatureItem(
      icon: Icons.people_outline,
      color: Colors.teal,
      title: 'Mentor Connect',
      body: 'Get guidance from verified mentors who have already walked the path you\'re considering.',
    ),
    _FeatureItem(
      icon: Icons.library_books_outlined,
      color: AppColors.info,
      title: 'Career Library',
      body: 'Browse all 61 curated careers with entrance paths, streams, and your personal fit score.',
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
          const Text('Everything You Need to Choose Right',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          const Text('One platform. Science-backed. Built for Indian students.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: _items.map((item) {
              return SizedBox(
                width: isWide ? 280 : double.infinity,
                child: _FeatureCard(item: item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _FeatureItem(
      {required this.icon, required this.color, required this.title, required this.body});
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

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
                  fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(item.body,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── How It Works ─────────────────────────────────────────────────────────────

class _HowItWorks extends StatelessWidget {
  static const _steps = [
    ('1', 'Take the KIT Assessment',
        'Answer 120 psychometric questions. Takes about 25 minutes.'),
    ('2', 'Get Your Career Blueprint',
        'AI analyses your scores and builds personalised roadmaps for your top 3 careers.'),
    ('3', 'Choose and Connect',
        'Lock your career path, connect with a mentor, and start building your future.'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 72),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF5EE), Color(0xFFF5F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text('How It Works',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 48),
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _steps
                      .map((s) =>
                          Expanded(child: _StepCard(step: s.$1, title: s.$2, body: s.$3)))
                      .toList(),
                )
              : Column(
                  children: _steps
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _StepCard(step: s.$1, title: s.$2, body: s.$3),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step, title, body;
  const _StepCard({required this.step, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(step,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── CTA ──────────────────────────────────────────────────────────────────────

class _CTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 56),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Ready to Find Your Career?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          const Text('Free to start. No credit card required.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70)),
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
            child: const Text('Start Your Assessment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Footer (public — reused by FAQ page) ────────────────────────────────────

class LandingFooter extends StatefulWidget {
  const LandingFooter({super.key});

  @override
  State<LandingFooter> createState() => _LandingFooterState();
}

class _LandingFooterState extends State<LandingFooter> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  static const _bg = Color(0xFF1B2333);
  static const _muted = Color(0xFF8B95A5);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _joinWaitlist() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      color: _bg,
      padding: EdgeInsets.fromLTRB(isWide ? 80 : 24, 56, isWide ? 80 : 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main columns
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImportantLinks(),
                    const SizedBox(width: 80),
                    _ContactColumn(),
                    const Spacer(),
                    _WaitlistForm(
                      controller: _emailController,
                      submitted: _submitted,
                      onSubmit: _joinWaitlist,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImportantLinks(),
                    const SizedBox(height: 40),
                    _ContactColumn(),
                    const SizedBox(height: 40),
                    _WaitlistForm(
                      controller: _emailController,
                      submitted: _submitted,
                      onSubmit: _joinWaitlist,
                    ),
                  ],
                ),
          const SizedBox(height: 48),
          // Bottom bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
            ),
            child: isWide
                ? Row(
                    children: [
                      Text('© 2025 - Present. All rights reserved.',
                          style: TextStyle(color: _muted, fontSize: 13)),
                      const Spacer(),
                      Row(
                        children: [
                          Text('Made in India with ', style: TextStyle(color: _muted, fontSize: 13)),
                          const Text('❤️', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('© 2025 - Present. All rights reserved.',
                          style: TextStyle(color: _muted, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Made in India with ', style: TextStyle(color: _muted, fontSize: 13)),
                          const Text('❤️', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ImportantLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IMPORTANT LINKS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        _FooterLink(label: 'Waitlist', onTap: () {}),
        const SizedBox(height: 12),
        _FooterLink(
          label: 'About',
          onTap: () => GoRouter.of(context).go('/about'),
        ),
        const SizedBox(height: 12),
        _FooterLink(label: 'FAQ', onTap: () => GoRouter.of(context).go('/faq')),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFCDD5E0),
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFFCDD5E0),
        ),
      ),
    );
  }
}

class _ContactColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTACT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        // Social icons row
        Row(
          children: [
            _SocialIcon(
              label: 'in',
              bgColor: const Color(0xFF0A66C2),
              onTap: () => _openUrl(_kLinkedIn),
            ),
            const SizedBox(width: 12),
            _SocialIcon(
              label: '▶',
              isInstagram: true,
              onTap: () => _openUrl(_kInstagram),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _openUrl('mailto:$_kEmail'),
          child: const Text(
            _kEmail,
            style: TextStyle(
              color: Color(0xFFCDD5E0),
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFFCDD5E0),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String label;
  final Color bgColor;
  final bool isInstagram;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.label,
    this.bgColor = Colors.transparent,
    this.isInstagram = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isInstagram ? null : bgColor,
          gradient: isInstagram
              ? const LinearGradient(
                  colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isInstagram
              ? const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18)
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}

class _WaitlistForm extends StatelessWidget {
  final TextEditingController controller;
  final bool submitted;
  final VoidCallback onSubmit;

  const _WaitlistForm({
    required this.controller,
    required this.submitted,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (submitted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 28),
          const SizedBox(height: 12),
          const Text(
            "You're on the list!",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "We'll reach out when early access opens.",
            style: TextStyle(color: Color(0xFF8B95A5), fontSize: 13),
          ),
        ],
      );
    }

    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your email address',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text('Join waitlist',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
