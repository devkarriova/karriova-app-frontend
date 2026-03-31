import 'package:flutter/material.dart';

/// Enum for question indicator states
enum QuestionIndicatorState {
  unattempted, // Question has not been answered
  current, // Currently viewing this question
  attempted, // Question has been answered
}

/// A circular indicator widget showing question number and status
class QuestionIndicator extends StatelessWidget {
  final int questionNumber; // Display number (1-based)
  final QuestionIndicatorState state;
  final VoidCallback? onTap;
  final bool isEnabled;

  const QuestionIndicator({
    super.key,
    required this.questionNumber,
    required this.state,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _getSemanticLabel(),
      button: isEnabled,
      enabled: isEnabled,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            shape: BoxShape.circle,
            border: Border.all(
              color: state == QuestionIndicatorState.current
                  ? _getBorderColor()
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: state == QuestionIndicatorState.current
                ? [
                    BoxShadow(
                      color: _getBackgroundColor().withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (state == QuestionIndicatorState.attempted) {
      return const Icon(
        Icons.check,
        color: Colors.white,
        size: 20,
      );
    }

    return Text(
      questionNumber.toString(),
      style: TextStyle(
        color: _getTextColor(),
        fontSize: 16,
        fontWeight: state == QuestionIndicatorState.current
            ? FontWeight.bold
            : FontWeight.w500,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case QuestionIndicatorState.unattempted:
        return const Color(0xFFE0E0E0); // Light gray
      case QuestionIndicatorState.current:
        return const Color(0xFF2196F3); // Blue
      case QuestionIndicatorState.attempted:
        return const Color(0xFF4CAF50); // Green
    }
  }

  Color _getTextColor() {
    switch (state) {
      case QuestionIndicatorState.unattempted:
        return const Color(0xFF757575); // Dark gray
      case QuestionIndicatorState.current:
      case QuestionIndicatorState.attempted:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    return const Color(0xFF1976D2); // Darker blue for border
  }

  String _getSemanticLabel() {
    final stateText = switch (state) {
      QuestionIndicatorState.unattempted => 'unattempted',
      QuestionIndicatorState.current => 'current question',
      QuestionIndicatorState.attempted => 'completed',
    };

    return 'Question $questionNumber, $stateText';
  }
}

/// Animated pulse effect for current question indicator
class PulsingQuestionIndicator extends StatefulWidget {
  final int questionNumber;
  final QuestionIndicatorState state;
  final VoidCallback? onTap;
  final bool isEnabled;

  const PulsingQuestionIndicator({
    super.key,
    required this.questionNumber,
    required this.state,
    this.onTap,
    this.isEnabled = true,
  });

  @override
  State<PulsingQuestionIndicator> createState() =>
      _PulsingQuestionIndicatorState();
}

class _PulsingQuestionIndicatorState extends State<PulsingQuestionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Only animate if this is the current question
    if (widget.state == QuestionIndicatorState.current) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingQuestionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == QuestionIndicatorState.current &&
        oldWidget.state != QuestionIndicatorState.current) {
      _controller.repeat(reverse: true);
    } else if (widget.state != QuestionIndicatorState.current) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state == QuestionIndicatorState.current) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: QuestionIndicator(
          questionNumber: widget.questionNumber,
          state: widget.state,
          onTap: widget.onTap,
          isEnabled: widget.isEnabled,
        ),
      );
    }

    return QuestionIndicator(
      questionNumber: widget.questionNumber,
      state: widget.state,
      onTap: widget.onTap,
      isEnabled: widget.isEnabled,
    );
  }
}
