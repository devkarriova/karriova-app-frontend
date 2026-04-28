import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:karriova_app/core/constants/app_colors.dart';

/// A rich animated loading widget for blueprint generation / fetching states.
///
/// Variants:
///  - [BlueprintLoadingVariant.options]  – loading the 3 career option cards
///  - [BlueprintLoadingVariant.generating] – generating a single blueprint (AI)
///  - [BlueprintLoadingVariant.detail]  – loading full blueprint detail
enum BlueprintLoadingVariant { options, generating, detail }

class BlueprintLoadingWidget extends StatefulWidget {
  final BlueprintLoadingVariant variant;

  /// Optional fixed message — if null, messages rotate automatically.
  final String? message;

  const BlueprintLoadingWidget({
    super.key,
    this.variant = BlueprintLoadingVariant.options,
    this.message,
  });

  @override
  State<BlueprintLoadingWidget> createState() => _BlueprintLoadingWidgetState();
}

class _BlueprintLoadingWidgetState extends State<BlueprintLoadingWidget>
    with TickerProviderStateMixin {
  int _messageIndex = 0;
  late Timer _messageTimer;

  static const _optionsMessages = [
    'Matching your personality…',
    'Comparing 50+ career profiles…',
    'Finding your top 3 options…',
    'Almost there…',
  ];

  static const _generatingMessages = [
    'Building your personalised roadmap…',
    'Crafting your 12-month milestones…',
    'Writing salary & growth projections…',
    'Identifying skills to develop…',
    'Mapping colleges & costs…',
    'This takes about 30–60 seconds…',
  ];

  static const _detailMessages = [
    'Loading your full career blueprint…',
    'Pulling in all 14 sections…',
    'Almost ready…',
  ];

  List<String> get _messages {
    switch (widget.variant) {
      case BlueprintLoadingVariant.generating:
        return _generatingMessages;
      case BlueprintLoadingVariant.detail:
        return _detailMessages;
      case BlueprintLoadingVariant.options:
        return _optionsMessages;
    }
  }

  @override
  void initState() {
    super.initState();
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    super.dispose();
  }

  Widget _buildSpinner() {
    switch (widget.variant) {
      case BlueprintLoadingVariant.generating:
        return const SpinKitCubeGrid(
          color: AppColors.primary,
          size: 72,
        );
      case BlueprintLoadingVariant.detail:
        return const SpinKitFadingFour(
          color: AppColors.secondary,
          size: 64,
        );
      case BlueprintLoadingVariant.options:
        return const SpinKitWave(
          color: AppColors.primary,
          size: 52,
          itemCount: 5,
        );
    }
  }

  String get _displayMessage =>
      widget.message ?? _messages[_messageIndex % _messages.length];

  IconData get _icon {
    switch (widget.variant) {
      case BlueprintLoadingVariant.generating:
        return Icons.auto_awesome;
      case BlueprintLoadingVariant.detail:
        return Icons.map_outlined;
      case BlueprintLoadingVariant.options:
        return Icons.psychology_outlined;
    }
  }

  String get _headline {
    switch (widget.variant) {
      case BlueprintLoadingVariant.generating:
        return 'Generating your blueprint';
      case BlueprintLoadingVariant.detail:
        return 'Opening your roadmap';
      case BlueprintLoadingVariant.options:
        return 'Finding your best matches';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(_icon, color: Colors.white, size: 36),
            ),

            const SizedBox(height: 28),

            // Spinner
            _buildSpinner(),

            const SizedBox(height: 28),

            // Headline
            Text(
              _headline,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Rotating sub-message with fade
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _displayMessage,
                key: ValueKey(_displayMessage),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (widget.variant == BlueprintLoadingVariant.generating) ...[
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'AI-powered  ·  personalised for you',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact inline spinner used inside a card button during generation.
class CardGeneratingIndicator extends StatelessWidget {
  const CardGeneratingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpinKitThreeBounce(
      color: Colors.white,
      size: 18,
    );
  }
}
