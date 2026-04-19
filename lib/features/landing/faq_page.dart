import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'landing_page.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LandingNavbar(currentRoute: '/faq'),
            _FaqContent(),
            const LandingFooter(),
          ],
        ),
      ),
    );
  }
}

class _FaqContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      color: const Color(0xFFF4F5F7),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'FAQs',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 48),
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _LeftColumn()),
                    const SizedBox(width: 64),
                    Expanded(child: _RightColumn()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LeftColumn(),
                    const SizedBox(height: 40),
                    _RightColumn(),
                  ],
                ),
          const SizedBox(height: 56),
          _LaunchQuestion(),
        ],
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FaqHeading('What is Karriova?'),
        const SizedBox(height: 12),
        _FaqParagraph(
          'Karriova is a global career guidance platform that helps students discover their real strengths and choose better-fit education and career paths with clarity and confidence.',
        ),
        const SizedBox(height: 40),
        _FaqHeading('Who should sign up?'),
        const SizedBox(height: 12),
        const _BulletList([
          'Students who are unsure about what to study or which career path to choose and want clear, AI-backed guidance.',
          'Parents who want trusted support to help their children make better educational and career decisions.',
          'Teachers who wish to guide students beyond marks and subjects toward suitable future paths.',
          'Career counsellors who want structured tools and insights to support their sessions.',
          'Working professionals or graduates who are considering a change in direction and want to realign their careers.',
        ]),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FaqHeading('How will it help?'),
        const SizedBox(height: 12),
        _FaqParagraph(
          'Karriova will help by turning vague career confusion into clear, personalised next steps for study and work.',
        ),
        const SizedBox(height: 16),
        const _BulletList([
          'It helps students discover their strengths, explore options and build a focused roadmap instead of guessing.',
          'It gives parents and teachers a common, structured view of a child\'s potential so they can guide with confidence.',
          'It equips counsellors and professionals with insights and tools to plan smarter choices, pivots and upskilling.',
        ]),
        const SizedBox(height: 40),
        _FaqHeading('Can schools join?'),
        const SizedBox(height: 12),
        _FaqParagraph(
          'Yes, schools can join to partner with Karriova, give their students access to structured career guidance, and use shared insights to strengthen counselling, parent communication, and future-readiness programs.',
        ),
      ],
    );
  }
}

class _LaunchQuestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 680),
      child: const Column(
        children: [
          Text(
            'When will Karriova launch?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Karriova is currently in pre-launch stage, and the first public version is planned to open to early access users soon; sign up with your email to get priority access and launch updates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqHeading extends StatelessWidget {
  final String text;
  const _FaqHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _FaqParagraph extends StatelessWidget {
  final String text;
  const _FaqParagraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textSecondary,
        height: 1.65,
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList(this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
