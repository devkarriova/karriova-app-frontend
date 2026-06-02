import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

const _kLinkedIn = 'https://www.linkedin.com/company/karriova/';
const _kInstagram = 'https://www.instagram.com/karriova/';
const _kEmail = 'info@karriova.com';
const _kBrandMark = 'assets/images/branding/karriova_logo_transparent.png';

const _bg = Color(0xFF0B0A09);
const _bg1 = Color(0xFF100E0C);
const _bg2 = Color(0xFF16130F);
const _bg3 = Color(0xFF1F1A15);
const _text = Color(0xFFF6F2EB);
const _textDim = Color(0xCCF6F2EB);
const _textFaint = Color(0x8CF6F2EB);
const _line = Color(0x17FFEEDD);
const _line2 = Color(0x29FFEEDD);
const _flame1 = Color(0xFFFF6B00);
const _flame2 = Color(0xFFFFA200);
const _flame3 = Color(0xFFFF4D1C);
const _ink = Color(0xFF1A0A00);

const _flameGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [_flame3, _flame1, _flame2],
  stops: [0, .45, 1],
);

const _flameGradientVertical = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [_flame2, _flame1, _flame3],
  stops: [0, .55, 1],
);

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $url');
  }
}

TextStyle _display({
  double? size,
  FontWeight weight = FontWeight.w700,
  Color color = _text,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

TextStyle _body({
  double? size,
  FontWeight weight = FontWeight.w500,
  Color color = _textDim,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

TextStyle _mono({
  double? size,
  FontWeight weight = FontWeight.w700,
  Color color = _textFaint,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.spaceMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _problemKey = GlobalKey();
  final _pillarsKey = GlobalKey();
  final _howKey = GlobalKey();
  final _schoolsKey = GlobalKey();
  final _finalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SelectionArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _LandingAtmospherePainter(),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LandingNavbar(
                    currentRoute: '/',
                    onProblem: () => _scrollTo(_problemKey),
                    onPlatform: () => _scrollTo(_pillarsKey),
                    onHow: () => _scrollTo(_howKey),
                    onSchools: () => _scrollTo(_schoolsKey),
                    onClaim: () => _scrollTo(_finalKey),
                  ),
                  _HeroSection(
                    animation: _controller,
                    onClaim: () => _scrollTo(_finalKey),
                    onHow: () => _scrollTo(_howKey),
                  ),
                  const _StatsBand(),
                  _ProblemSection(key: _problemKey),
                  _PillarsSection(key: _pillarsKey),
                  _HowSection(key: _howKey),
                  const _MoatSection(),
                  _SchoolsSection(key: _schoolsKey),
                  const _SocialProofSection(),
                  _FinalCtaSection(key: _finalKey),
                  LandingFooter(
                    onProblem: () => _scrollTo(_problemKey),
                    onHow: () => _scrollTo(_howKey),
                    onSchools: () => _scrollTo(_schoolsKey),
                    onClaim: () => _scrollTo(_finalKey),
                    onProduct: () => _scrollTo(_pillarsKey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LandingNavbar extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onProblem;
  final VoidCallback? onPlatform;
  final VoidCallback? onReport;
  final VoidCallback? onStories;
  final VoidCallback? onHow;
  final VoidCallback? onSchools;
  final VoidCallback? onClaim;

  const LandingNavbar({
    super.key,
    required this.currentRoute,
    this.onProblem,
    this.onPlatform,
    this.onReport,
    this.onStories,
    this.onHow,
    this.onSchools,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 920;
    final onLanding = currentRoute == '/';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width >= 1120 ? 46 : 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _bg.withOpacity(.78),
        border: const Border(bottom: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.20),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              _Brand(onTap: () => context.go('/')),
              const Spacer(),
              if (isWide) ...[
                if (onLanding) ...[
                  _NavLink(label: 'The Problem', onTap: onProblem ?? () {}),
                  _NavLink(label: 'What you get', onTap: onPlatform ?? () {}),
                  _NavLink(label: 'How it works', onTap: onHow ?? () {}),
                  _NavLink(label: 'For Schools', onTap: onSchools ?? () {}),
                ],
                if (!onLanding) ...[
                  _NavLink(
                    label: 'Home',
                    active: currentRoute == '/',
                    onTap: () => context.go('/'),
                  ),
                  _NavLink(
                    label: 'About',
                    active: currentRoute == '/about',
                    onTap: () => context.go('/about'),
                  ),
                  _NavLink(
                    label: 'FAQ',
                    active: currentRoute == '/faq',
                    onTap: () => context.go('/faq'),
                  ),
                ],
                const SizedBox(width: 12),
              ],
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text('Log in',
                    style: _body(size: 13, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              _FlameButton(
                label: onLanding ? 'Claim Your Profile' : 'Start Free',
                compact: !isWide,
                onTap: onClaim ?? () => context.go('/login?mode=signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final VoidCallback onTap;

  const _Brand({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _bg1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line2),
                boxShadow: [
                  BoxShadow(
                    color: _flame1.withOpacity(.22),
                    blurRadius: 26,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Image.asset(
                  _kBrandMark,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_fire_department_rounded,
                    color: _flame2,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Text(
              'Karriova',
              style: _display(
                  size: 21, weight: FontWeight.w800, letterSpacing: -.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.active || _hovered ? _text : _textFaint;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TextButton(
        onPressed: widget.onTap,
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label,
                style: _body(size: 13, weight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 2,
              width: widget.active || _hovered ? 28 : 0,
              decoration: BoxDecoration(
                gradient: _flameGradient,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onClaim;
  final VoidCallback onHow;

  const _HeroSection({
    required this.animation,
    required this.onClaim,
    required this.onHow,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 980;

    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _HeroGridPainter())),
        _SectionShell(
          top: isWide ? 86 : 58,
          bottom: isWide ? 88 : 58,
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 10,
                      child: _HeroCopy(onClaim: onClaim, onHow: onHow),
                    ),
                    const SizedBox(width: 54),
                    Expanded(
                      flex: 8,
                      child: _HeroVisual(animation: animation),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCopy(onClaim: onClaim, onHow: onHow),
                    const SizedBox(height: 42),
                    _HeroVisual(animation: animation),
                  ],
                ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final VoidCallback onClaim;
  final VoidCallback onHow;

  const _HeroCopy({required this.onClaim, required this.onHow});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 560
        ? 46.0
        : width < 980
            ? 68.0
            : 82.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow(text: 'India\'s Pre-Career Professional Network'),
        const SizedBox(height: 26),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: 'Build your\n',
                  style: _display(
                      size: titleSize, height: 1.02, letterSpacing: -2.4)),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: _FlameText(
                  'career profile',
                  style: _display(
                      size: titleSize, height: 1.02, letterSpacing: -2.4),
                ),
              ),
              TextSpan(
                  text: '\nbefore college even starts.',
                  style: _display(
                      size: titleSize, height: 1.02, letterSpacing: -2.4)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text.rich(
            TextSpan(
              text:
                  'Students come for guidance. They stay for their network. They never leave - because their ',
              style: _body(size: width < 560 ? 16 : 19, height: 1.72),
              children: [
                TextSpan(
                    text: 'profile grows here.',
                    style: _body(
                        size: width < 560 ? 16 : 19,
                        weight: FontWeight.w800,
                        color: _text)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 38),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _FlameButton(
                label: 'Take the Free KIT Test', large: true, onTap: onClaim),
            _GhostButton(label: 'How it works', large: true, onTap: onHow),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AvatarStack(),
            const SizedBox(width: 15),
            Flexible(
              child: Text.rich(
                TextSpan(
                  text: 'Join ',
                  style: _body(size: 14),
                  children: [
                    TextSpan(
                        text: 'students already building',
                        style: _body(
                            size: 14, color: _text, weight: FontWeight.w800)),
                    const TextSpan(text: ' their future.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  final Animation<double> animation;

  const _HeroVisual({required this.animation});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Container(
              width: 390,
              height: 390,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _flame1.withOpacity(.12),
                boxShadow: [
                  BoxShadow(color: _flame1.withOpacity(.34), blurRadius: 110),
                ],
              ),
            ),
          ),
          _FloatMotion(
            animation: animation,
            child: const _ProfileCard(),
          ),
          Positioned(
            left: -18,
            bottom: 74,
            child: _FloatMotion(
              animation: animation,
              child: const _FloatingBadge(
                small: 'Blueprint match',
                big: '330+ careers mapped',
                icon: Icons.track_changes_rounded,
              ),
            ),
          ),
          Positioned(
            right: -14,
            top: 84,
            child: _FloatMotion(
              animation: animation,
              reverse: true,
              child: const _FloatingBadge(
                small: '21-parameter',
                big: 'AI Career Test',
                icon: Icons.bar_chart_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatMotion extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final bool reverse;

  const _FloatMotion({
    required this.animation,
    required this.child,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: RepaintBoundary(child: child),
      builder: (context, child) {
        final direction = reverse ? -1.0 : 1.0;
        final dy = math.sin(animation.value * math.pi * 2) * 8;
        return Transform.translate(
          offset: Offset(0, dy * direction),
          transformHitTests: false,
          child: child,
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      constraints: const BoxConstraints(maxWidth: 390),
      decoration: BoxDecoration(
        color: _bg1,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.42),
            blurRadius: 48,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 124,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _flame1.withOpacity(.92),
                  _flame2.withOpacity(.62),
                  _bg3,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -34,
                  top: -48,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.14),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _bg3.withOpacity(.78),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _line2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: _flame2, size: 14),
                        const SizedBox(width: 6),
                        Text('Portfolio-ready',
                            style: _mono(size: 10.5, color: _text)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 28,
                  bottom: -34,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: _flameGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: _bg1, width: 4),
                    ),
                    child: Center(
                      child: Text('A', style: _display(size: 30, color: _ink)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aarav Sharma', style: _display(size: 21)),
                const SizedBox(height: 6),
                Text('Class 11 - Science - Jodhpur, RJ',
                    style: _body(size: 13.5, color: _textFaint)),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.035),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _line),
                  ),
                  child: Row(
                    children: [
                      const _ScoreRing(score: 84),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('KIT Score', style: _mono(size: 10.5)),
                            const SizedBox(height: 6),
                            Text.rich(
                              TextSpan(
                                text: 'Top match: ',
                                style: _body(size: 14, color: _textDim),
                                children: [
                                  TextSpan(
                                    text: 'Product Design',
                                    style: _body(
                                        size: 14,
                                        color: _flame2,
                                        weight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('Profile highlights',
                    style: _mono(size: 10.5, letterSpacing: 1.1)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _SkillChip(label: 'Debate Nationals', highlighted: true),
                    _SkillChip(label: 'NSO Gold', highlighted: true),
                    _SkillChip(label: 'Python'),
                    _SkillChip(label: 'Football - State'),
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

class _StatsBand extends StatelessWidget {
  const _StatsBand();

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: _line)),
      ),
      child: _SectionShell(
        top: 0,
        bottom: 0,
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: narrow ? 1 : 3,
          childAspectRatio: narrow ? 4.2 : 2.45,
          children: const [
            _StatBlock(
                number: '95M+',
                label: 'Students in India, one career to build',
                flame: true),
            _StatBlock(
                number: '330+', label: 'Career paths across 25 categories'),
            _StatBlock(
                number: 'Zero',
                label: 'Direct competitors. We built the category.',
                flame: true),
          ],
        ),
      ),
    );
  }
}

class _ProblemSection extends StatelessWidget {
  const _ProblemSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow(text: 'The problem nobody names'),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Text(
              'You\'re picking a future blind - and staying invisible while you do it.',
              style: _display(
                  size: _sectionTitleSize(context),
                  height: 1.06,
                  letterSpacing: -1.5),
            ),
          ),
          const SizedBox(height: 44),
          const _ResponsiveGrid(
            minTileWidth: 280,
            gap: 20,
            children: [
              _ProblemCard(
                  big: '330+',
                  title: 'Careers you\'ve never heard of',
                  body:
                      'Most students choose from the same 12 names because nobody shows them the full map.'),
              _ProblemCard(
                  big: '0',
                  title: 'Invisible till you graduate',
                  body:
                      'Your certificates, projects, interests, and evidence live in random folders until it is too late.'),
              _ProblemCard(
                  big: '?',
                  title: 'Advice that doesn\'t stick',
                  body:
                      'A test result gets forgotten. A profile, network, and roadmap can compound every year.'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillarsSection extends StatelessWidget {
  const _PillarsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 820;
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow(text: 'What you actually get'),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Text(
              'Not a quiz. A career profile that compounds.',
              style: _display(
                  size: _sectionTitleSize(context),
                  height: 1.06,
                  letterSpacing: -1.5),
            ),
          ),
          const SizedBox(height: 56),
          _ResponsiveGrid(
            minTileWidth: narrow ? 260 : 430,
            gap: 20,
            children: const [
              _PillarCard(
                icon: Icons.hub_outlined,
                title: 'KIT - AI Career Test',
                tag: '21 params',
                body:
                    'A 21-parameter psychometric engine - RIASEC, personality, aptitude and career orientation - turns minutes into your personalised Career Blueprint across 330+ careers.',
              ),
              _PillarCard(
                icon: Icons.article_outlined,
                title: 'Dynamic Blueprint',
                body:
                    'Not a one-time report. A living roadmap that updates as you grow, achieve, and change your mind.',
              ),
              _PillarCard(
                icon: Icons.inventory_2_outlined,
                title: 'Career Portfolio',
                body:
                    'Collect certificates, projects, sports, Olympiads and CCA in one organized profile that is easy to understand.',
              ),
              _PillarCard(
                icon: Icons.groups_2_outlined,
                title: 'The Network',
                body:
                    'Connect with peers, seniors, mentors and pros. Build your profile from Class 9 - and never start from zero.',
              ),
              _PillarCard(
                icon: Icons.school_outlined,
                title: 'For Schools',
                body:
                    'A counsellor dashboard plus analytics that turns guidance into a measurable program.',
                wide: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HowSection extends StatelessWidget {
  const _HowSection({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow(text: 'The loop'),
          const SizedBox(height: 20),
          Text(
            'Four steps from confused to connected.',
            style: _display(
                size: _sectionTitleSize(context),
                height: 1.06,
                letterSpacing: -1.5),
          ),
          const SizedBox(height: 64),
          Stack(
            children: [
              if (!narrow)
                Positioned(
                  top: 35,
                  left: 86,
                  right: 86,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: _flameGradient,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              const _ResponsiveGrid(
                minTileWidth: 210,
                gap: 22,
                children: [
                  _StepCard(
                      number: '1',
                      title: 'Take KIT',
                      body:
                          'Answer the AI Career Test across personality, interest, aptitude and career orientation.'),
                  _StepCard(
                      number: '2',
                      title: 'Get your Blueprint',
                      body:
                          'See matched careers, why they fit, where they may fail, and what to do next.'),
                  _StepCard(
                      number: '3',
                      title: 'Build your profile',
                      body:
                          'Add certificates, projects, skills, and evidence so your story becomes easier to see.'),
                  _StepCard(
                      number: '4',
                      title: 'Join the network',
                      body:
                          'Connect with peers, seniors, mentors, schools and professionals on the same path.'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoatSection extends StatelessWidget {
  const _MoatSection();

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 620,
            height: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: _flame1.withOpacity(.08),
              boxShadow: [
                BoxShadow(color: _flame1.withOpacity(.24), blurRadius: 110),
              ],
            ),
          ),
          Column(
            children: [
              const _Eyebrow(
                  text: 'Why Karriova != a career app', centered: true),
              const SizedBox(height: 30),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                        text: 'Reports get forgotten.\n',
                        style: _display(
                            size: _moatTitleSize(context),
                            height: 1.02,
                            letterSpacing: -1.8)),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: _FlameText('Profiles don\'t.',
                          style: _display(
                              size: _moatTitleSize(context),
                              height: 1.02,
                              letterSpacing: -1.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 660),
                child: Text(
                  'Apps give you a test and a goodbye. Karriova gives you a living profile and a network that can grow with you year after year. That is the moat - and it is yours.',
                  textAlign: TextAlign.center,
                  style: _body(size: 19, height: 1.65),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'Arrive at college with your story already taking shape.',
                textAlign: TextAlign.center,
                style: _display(size: 25, weight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SchoolsSection extends StatelessWidget {
  const _SchoolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    return _SectionShell(
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: _SchoolsCopy()),
                const SizedBox(width: 56),
                Expanded(child: _DashboardPreview()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SchoolsCopy(),
                SizedBox(height: 40),
                _DashboardPreview(),
              ],
            ),
    );
  }
}

class _SchoolsCopy extends StatelessWidget {
  const _SchoolsCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow(text: 'For Schools - B2B'),
        const SizedBox(height: 18),
        Text(
          'Give every counsellor a superpower.',
          style: _display(
              size: _sectionTitleSize(context),
              height: 1.06,
              letterSpacing: -1.5),
        ),
        const SizedBox(height: 18),
        Text(
          'A white-label counsellor dashboard with real analytics - see every student\'s blueprint, track engagement, and prove outcomes. Free to start.',
          style: _body(size: 17, height: 1.7),
        ),
        const SizedBox(height: 26),
        const _Bullet(
            text:
                'Counsellor dashboard - every student\'s blueprint in one view.'),
        const _Bullet(
            text:
                'Cohort analytics - engagement, interests and readiness, at a glance.'),
        const _Bullet(text: 'White-label - your school\'s brand, our engine.'),
        const SizedBox(height: 34),
        _FlameButton(
          label: 'Partner with us',
          large: true,
          onTap: () => _openUrl('mailto:$_kEmail?subject=School%20partnership'),
        ),
      ],
    );
  }
}

class _SocialProofSection extends StatelessWidget {
  const _SocialProofSection();

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      top: 82,
      child: Column(
        children: [
          const _Eyebrow(
              text: 'Trusted by schools across Rajasthan', centered: true),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 28,
            runSpacing: 14,
            children: const [
              _SchoolName('Jodhpur Public School'),
              _SchoolName('Mayoor Academy'),
              _SchoolName('Rajmata Vidyalaya'),
              _SchoolName('Desert Springs School'),
              _SchoolName('Marwar International'),
            ],
          ),
          const SizedBox(height: 60),
          const _ResponsiveGrid(
            minTileWidth: 285,
            gap: 20,
            children: [
              _TestimonialCard(
                quote:
                    'I genuinely had no idea Product Design was a thing. KIT showed me, and now my whole profile is built around it. Wild.',
                initials: 'RP',
                name: 'Riya P.',
                role: 'Class 12 - Jaipur',
              ),
              _TestimonialCard(
                quote:
                    'My debate medals and coding stuff are finally in one place. Felt like I existed online for the first time, lol.',
                initials: 'KV',
                name: 'Kabir V.',
                role: 'Class 10 - Jodhpur',
              ),
              _TestimonialCard(
                quote:
                    'As a counsellor, I can finally see what every kid is actually into. The dashboard does in seconds what took me weeks.',
                initials: 'SC',
                name: 'School Counsellor',
                role: 'Rajasthan',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinalCtaSection extends StatefulWidget {
  const _FinalCtaSection({super.key});

  @override
  State<_FinalCtaSection> createState() => _FinalCtaSectionState();
}

class _FinalCtaSectionState extends State<_FinalCtaSection> {
  final _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 620;
    return _SectionShell(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: narrow ? 24 : 54,
          vertical: narrow ? 48 : 72,
        ),
        decoration: BoxDecoration(
          color: _bg1,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: _line2),
          boxShadow: [
            BoxShadow(color: _flame1.withOpacity(.14), blurRadius: 70),
          ],
        ),
        child: Column(
          children: [
            const _Eyebrow(text: 'Early access - Free', centered: true),
            const SizedBox(height: 22),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(
                      text: 'Your career profile ',
                      style: _display(
                          size: _finalTitleSize(context),
                          height: 1.02,
                          letterSpacing: -1.9)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: _FlameText('starts now.',
                        style: _display(
                            size: _finalTitleSize(context),
                            height: 1.02,
                            letterSpacing: -1.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(
                'Spots in the first cohort are limited. Claim your profile, take the free KIT test, and start showing your story with more clarity.',
                textAlign: TextAlign.center,
                style: _body(size: 17, height: 1.65),
              ),
            ),
            const SizedBox(height: 38),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: narrow
                  ? Column(
                      children: [
                        _EmailField(controller: _controller),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: _FlameButton(
                              label: 'Get Early Access',
                              large: true,
                              onTap: _submit),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _EmailField(controller: _controller)),
                        const SizedBox(width: 10),
                        _FlameButton(
                            label: 'Get Early Access',
                            large: true,
                            onTap: _submit),
                      ],
                    ),
            ),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(
                text: 'No spam. ',
                style: _mono(size: 12, weight: FontWeight.w500),
                children: [
                  TextSpan(
                      text: 'Just your future,',
                      style: _mono(size: 12, color: _flame2)),
                  const TextSpan(text: ' a little earlier than everyone else.'),
                ],
              ),
            ),
            if (_submitted) ...[
              const SizedBox(height: 22),
              Text(
                'You are on the list. Welcome to Karriova - check your inbox.',
                style: _body(size: 16, color: _flame2, weight: FontWeight.w800),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _submit() {
    setState(() => _submitted = true);
  }
}

class LandingFooter extends StatefulWidget {
  final VoidCallback? onProblem;
  final VoidCallback? onHow;
  final VoidCallback? onSchools;
  final VoidCallback? onClaim;
  final VoidCallback? onProduct;

  const LandingFooter({
    super.key,
    this.onProblem,
    this.onHow,
    this.onSchools,
    this.onClaim,
    this.onProduct,
  });

  @override
  State<LandingFooter> createState() => _LandingFooterState();
}

class _LandingFooterState extends State<LandingFooter> {
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _line)),
      ),
      child: _SectionShell(
        top: 72,
        bottom: 38,
        child: Column(
          children: [
            narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FooterBrand(),
                      const SizedBox(height: 34),
                      _FooterColumns(
                        onProblem: widget.onProblem,
                        onHow: widget.onHow,
                        onSchools: widget.onSchools,
                        onClaim: widget.onClaim,
                        onProduct: widget.onProduct,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 16, child: _FooterBrand()),
                      const SizedBox(width: 40),
                      Expanded(
                        flex: 24,
                        child: _FooterColumns(
                          onProblem: widget.onProblem,
                          onHow: widget.onHow,
                          onSchools: widget.onSchools,
                          onClaim: widget.onClaim,
                          onProduct: widget.onProduct,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 56),
            Container(height: 1, color: _line),
            const SizedBox(height: 26),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                    'Copyright 2026 Karriova Pvt. Ltd. - Jodhpur, Rajasthan, India',
                    style: _body(size: 13, color: _textFaint)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FooterSmallLink(
                        label: 'Legal & Safety',
                        onTap: () => context.go('/legal')),
                    const SizedBox(width: 24),
                    _FooterSmallLink(
                        label: 'Privacy',
                        onTap: () => context.go('/legal/privacy-policy')),
                    const SizedBox(width: 24),
                    _FooterSmallLink(
                        label: 'Terms',
                        onTap: () => context.go('/legal/terms-of-service')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  final Widget child;
  final double top;
  final double bottom;

  const _SectionShell({
    required this.child,
    this.top = 104,
    this.bottom = 104,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        width >= 1200
            ? 40
            : width >= 760
                ? 30
                : 20,
        top,
        width >= 1200
            ? 40
            : width >= 760
                ? 30
                : 20,
        bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;
  final double gap;

  const _ResponsiveGrid({
    required this.children,
    required this.minTileWidth,
    this.gap = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            math.max(1, (constraints.maxWidth / minTileWidth).floor());
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children.map((child) {
            final isWidePillar =
                child is _PillarCard && child.wide && columns > 1;
            return SizedBox(
              width: isWidePillar ? constraints.maxWidth : width,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  final bool centered;

  const _Eyebrow({required this.text, this.centered = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: centered ? Alignment.center : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _flame1.withOpacity(.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _flame1.withOpacity(.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hub_outlined, color: _flame2, size: 16),
            const SizedBox(width: 10),
            Text(text.toUpperCase(),
                style: _mono(size: 11, color: _flame2, letterSpacing: 1.1)),
          ],
        ),
      ),
    );
  }
}

class _FlameText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _FlameText(this.text, {required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => _flameGradient.createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class _FlameButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool large;
  final bool compact;

  const _FlameButton({
    required this.label,
    required this.onTap,
    this.large = false,
    this.compact = false,
  });

  @override
  State<_FlameButton> createState() => _FlameButtonState();
}

class _FlameButtonState extends State<_FlameButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _hovered ? 1.02 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: _flameGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                  color: _flame1.withOpacity(_hovered ? .36 : .22),
                  blurRadius: _hovered ? 34 : 22,
                  offset: const Offset(0, 14)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact
                      ? 15
                      : widget.large
                          ? 24
                          : 18,
                  vertical: widget.large ? 17 : 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.label,
                        style: _body(
                            size: widget.large ? 15 : 13,
                            color: _ink,
                            weight: FontWeight.w900)),
                    if (!widget.compact) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 18, color: _ink),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool large;

  const _GhostButton(
      {required this.label, required this.onTap, this.large = false});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _text,
        side: const BorderSide(color: _line2),
        padding: EdgeInsets.symmetric(
            horizontal: large ? 24 : 18, vertical: large ? 17 : 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: Colors.white.withOpacity(.03),
      ),
      child: Text(label,
          style: _body(
              size: large ? 15 : 13, color: _text, weight: FontWeight.w800)),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    const avatars = [
      ('AS', Color(0xFFFFB44D)),
      ('RP', Color(0xFFFF8A3D)),
      ('KV', Color(0xFFFF6B3D)),
      ('+', Color(0xFFFFA200)),
    ];
    return SizedBox(
      width: 112,
      height: 36,
      child: Stack(
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(
              left: i * 25,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: avatars[i].$2,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 2),
                ),
                child: Center(
                  child:
                      Text(avatars[i].$1, style: _mono(size: 11, color: _ink)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final String small;
  final String big;
  final IconData icon;

  const _FloatingBadge({
    required this.small,
    required this.big,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _bg1.withOpacity(.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.32),
              blurRadius: 26,
              offset: const Offset(0, 14)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: _flameGradient,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _ink, size: 17),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(small.toUpperCase(),
                  style: _mono(size: 9.5, weight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(big,
                  style:
                      _body(size: 13, color: _text, weight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;

  const _ScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScoreRingPainter(score / 100),
      child: SizedBox(
        width: 66,
        height: 66,
        child: Center(child: Text('$score', style: _display(size: 17))),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _SkillChip({required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (highlighted) ...[
            const Icon(Icons.star_rounded, size: 14, color: _flame2),
            const SizedBox(width: 5),
          ],
          Text(label,
              style:
                  _body(size: 12.5, color: _textDim, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String number;
  final String label;
  final bool flame;

  const _StatBlock({
    required this.number,
    required this.label,
    this.flame = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: _line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          flame
              ? _FlameText(number,
                  style: _display(size: 58, height: 1, letterSpacing: -2))
              : Text(number,
                  style: _display(size: 58, height: 1, letterSpacing: -2)),
          const SizedBox(height: 12),
          Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _body(size: 13.5, height: 1.35)),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatefulWidget {
  final String big;
  final String title;
  final String body;

  const _ProblemCard({
    required this.big,
    required this.title,
    required this.body,
  });

  @override
  State<_ProblemCard> createState() => _ProblemCardState();
}

class _ProblemCardState extends State<_ProblemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      onHover: (value) => setState(() => _hovered = value),
      child: Container(
        constraints: const BoxConstraints(minHeight: 255),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered ? _bg2 : _bg1,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _hovered ? _line2 : _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlameText(widget.big,
                style: _display(size: 56, height: 1, letterSpacing: -2.4)),
            const SizedBox(height: 42),
            Text(widget.title,
                style: _display(size: 22, weight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(widget.body, style: _body(size: 14.5, height: 1.58)),
          ],
        ),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? tag;
  final String body;
  final bool wide;

  const _PillarCard({
    required this.icon,
    required this.title,
    required this.body,
    this.tag,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: wide ? 136 : 184),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: wide ? _bg2 : _bg1,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _line),
          ),
          child: wide
              ? Row(
                  children: [
                    _PillarIcon(icon),
                    const SizedBox(width: 20),
                    Expanded(
                        child: _PillarText(title: title, body: body, tag: tag)),
                    const SizedBox(width: 18),
                    const Icon(Icons.arrow_forward_rounded, color: _flame2),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PillarIcon(icon),
                    const SizedBox(width: 20),
                    Expanded(
                        child: _PillarText(title: title, body: body, tag: tag)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PillarIcon extends StatelessWidget {
  final IconData icon;

  const _PillarIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _flame1.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _flame1.withOpacity(.24)),
      ),
      child: Icon(icon, color: _flame2, size: 26),
    );
  }
}

class _PillarText extends StatelessWidget {
  final String title;
  final String body;
  final String? tag;

  const _PillarText({required this.title, required this.body, this.tag});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            Text(title, style: _display(size: 20, weight: FontWeight.w700)),
            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: _flame1.withOpacity(.30)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(tag!.toUpperCase(),
                    style: _mono(size: 10, color: _flame2, letterSpacing: 1.1)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(body, style: _body(size: 14.5, height: 1.62)),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _StepCard({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: _flameGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.transparent),
              boxShadow: [
                BoxShadow(color: _flame1.withOpacity(.24), blurRadius: 26),
              ],
            ),
            child: Center(
                child: Text(number, style: _display(size: 22, color: _ink))),
          ),
          const SizedBox(height: 22),
          Text(title, style: _display(size: 22)),
          const SizedBox(height: 10),
          Text(body, style: _body(size: 14.5, height: 1.62)),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, color: _flame2, size: 19),
          const SizedBox(width: 13),
          Expanded(child: Text(text, style: _body(size: 15.5, height: 1.55))),
        ],
      ),
    );
  }
}

class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg1,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.36),
              blurRadius: 44,
              offset: const Offset(0, 24)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: _bg3,
            child: Row(
              children: [
                const _WindowDot(color: Color(0xFFFF5F56)),
                const SizedBox(width: 7),
                const _WindowDot(color: Color(0xFFFFBD2E)),
                const SizedBox(width: 7),
                const _WindowDot(color: Color(0xFF27C93F)),
                const SizedBox(width: 10),
                Text('karriova.school / dashboard', style: _mono(size: 11)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(
                        child: _DashboardKpi(
                            label: 'Active students', value: '1,248')),
                    SizedBox(width: 14),
                    Expanded(
                        child: _DashboardKpi(
                            label: 'Blueprints done', value: '92%')),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 210,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.035),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Interest categories - this cohort',
                          style: _mono(size: 10)),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            _Bar(height: .42),
                            _Bar(height: .68),
                            _Bar(height: .54),
                            _Bar(height: .88),
                            _Bar(height: .36),
                            _Bar(height: .72),
                            _Bar(height: .60),
                            _Bar(height: .48),
                            _Bar(height: .80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardKpi extends StatelessWidget {
  final String label;
  final String value;

  const _DashboardKpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: _mono(size: 10)),
          const SizedBox(height: 6),
          Text(value, style: _display(size: 30)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;

  const _Bar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: height,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: _flameGradientVertical,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  final Color color;

  const _WindowDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _SchoolName extends StatelessWidget {
  final String name;

  const _SchoolName(this.name);

  @override
  Widget build(BuildContext context) {
    return Text(name,
        style: _display(size: 18, color: _textFaint, weight: FontWeight.w700));
  }
}

class _TestimonialCard extends StatelessWidget {
  final String quote;
  final String initials;
  final String name;
  final String role;

  const _TestimonialCard({
    required this.quote,
    required this.initials,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 260),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: _bg1,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('*****',
                  style: _mono(size: 14, color: _flame2, letterSpacing: 3)),
              const SizedBox(height: 16),
              Text('"$quote"',
                  style: _body(
                      size: 16,
                      color: _text,
                      height: 1.55,
                      weight: FontWeight.w600)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _bg3,
                      shape: BoxShape.circle,
                      border: Border.all(color: _line2),
                    ),
                    child: Center(
                        child: Text(initials,
                            style: _mono(size: 13, color: _flame2))),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: _body(
                              size: 14.5,
                              color: _text,
                              weight: FontWeight.w800)),
                      Text(role, style: _body(size: 12.5, color: _textFaint)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: _body(size: 15.5, color: _text, weight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'you@school.edu - get early access',
        hintStyle: _body(size: 15, color: _textFaint),
        filled: true,
        fillColor: Colors.white.withOpacity(.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: _line2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: _flame1),
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Brand(onTap: () => context.go('/')),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            text: 'Connect.',
            style: _display(size: 17, color: _flame2, weight: FontWeight.w700),
            children: [
              TextSpan(
                  text: ' Discover. Succeed.',
                  style: _display(size: 17, weight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Text(
            'India\'s Pre-Career Professional Network. Build a career profile before your career even begins.',
            style: _body(size: 14, height: 1.6),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            _SocialButton(
                icon: Icons.camera_alt_outlined,
                onTap: () => _openUrl(_kInstagram)),
            const SizedBox(width: 12),
            _SocialButton(
                icon: Icons.business_center_outlined,
                onTap: () => _openUrl(_kLinkedIn)),
          ],
        ),
      ],
    );
  }
}

class _FooterColumns extends StatelessWidget {
  final VoidCallback? onProblem;
  final VoidCallback? onHow;
  final VoidCallback? onSchools;
  final VoidCallback? onClaim;
  final VoidCallback? onProduct;

  const _FooterColumns({
    this.onProblem,
    this.onHow,
    this.onSchools,
    this.onClaim,
    this.onProduct,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minTileWidth: 140,
      gap: 28,
      children: [
        _FooterColumn(
          title: 'Product',
          links: [
            _FooterLink('KIT Career Test', route: '/assessment'),
            _FooterLink('Dynamic Blueprint', onTap: onProduct),
            _FooterLink('Career Portfolio', onTap: onProduct),
            _FooterLink('The Network', route: '/mentors'),
          ],
        ),
        _FooterColumn(
          title: 'Company',
          links: [
            _FooterLink('The Problem', onTap: onProblem),
            _FooterLink('How it works', onTap: onHow),
            _FooterLink('For Schools', onTap: onSchools),
            _FooterLink('Early Access', onTap: onClaim),
          ],
        ),
        _FooterColumn(
          title: 'Connect',
          links: [
            _FooterLink('Careers', route: '/careers'),
            _FooterLink('Contact', externalUrl: 'mailto:$_kEmail'),
          ],
        ),
      ],
    );
  }
}

class _FooterLink {
  final String label;
  final String? route;
  final String? externalUrl;
  final VoidCallback? onTap;

  const _FooterLink(
    this.label, {
    this.route,
    this.externalUrl,
    this.onTap,
  });

  bool get hasAction => onTap != null || route != null || externalUrl != null;
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<_FooterLink> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    final activeLinks = links.where((link) => link.hasAction).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: _mono(size: 11, letterSpacing: 1.4)),
        const SizedBox(height: 18),
        for (final link in activeLinks)
          _FooterTextLink(
            link: link,
          ),
      ],
    );
  }
}

class _FooterTextLink extends StatelessWidget {
  final _FooterLink link;

  const _FooterTextLink({required this.link});

  @override
  Widget build(BuildContext context) {
    final style = _body(
      size: 14.5,
      color: _textDim,
    );

    return InkWell(
      onTap: () {
        if (link.onTap != null) {
          link.onTap!();
        } else if (link.route != null) {
          context.go(link.route!);
        } else if (link.externalUrl != null) {
          _openUrl(link.externalUrl!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Text(link.label, style: style),
      ),
    );
  }
}

class _FooterSmallLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterSmallLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Text(label, style: _body(size: 13, color: _textFaint)));
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: _line2),
        ),
        child: Icon(icon, size: 18, color: _textDim),
      ),
    );
  }
}

class _HoverLift extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool>? onHover;

  const _HoverLift({required this.child, this.onHover});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        widget.onHover?.call(true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
        widget.onHover?.call(false);
      },
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        offset: _hovered ? const Offset(0, -.018) : Offset.zero,
        child: widget.child,
      ),
    );
  }
}

class _LandingAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final top = Offset(size.width * .1, 60);
    final right = Offset(size.width * .96, size.height * .12);
    paint.shader = RadialGradient(
      colors: [_flame1.withOpacity(.16), Colors.transparent],
    ).createShader(Rect.fromCircle(center: top, radius: 410));
    canvas.drawCircle(top, 410, paint);
    paint.shader = RadialGradient(
      colors: [_flame2.withOpacity(.10), Colors.transparent],
    ).createShader(Rect.fromCircle(center: right, radius: 390));
    canvas.drawCircle(right, 390, paint);
  }

  @override
  bool shouldRepaint(covariant _LandingAtmospherePainter oldDelegate) => false;
}

class _HeroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.035)
      ..strokeWidth = 1;
    const gap = 58.0;
    for (double x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;

  _ScoreRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final base = Paint()
      ..color = Colors.white.withOpacity(.08)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final arc = Paint()
      ..shader = _flameGradient.createShader(Offset.zero & size)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 5, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

double _sectionTitleSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 560) return 34;
  if (width < 980) return 46;
  return 58;
}

double _moatTitleSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 560) return 40;
  if (width < 980) return 58;
  return 78;
}

double _finalTitleSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 560) return 38;
  if (width < 980) return 56;
  return 76;
}
