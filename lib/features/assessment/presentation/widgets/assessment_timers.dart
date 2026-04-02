import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';

/// Two countdown bars. Clock icon + time rides the shrinking tip of each bar.
class AssessmentTimers extends StatefulWidget {
  final Duration? remainingTestTime;
  final Duration? remainingSectionTime;
  final String? sectionName;
  final int totalTestDurationMinutes;
  final int sectionDurationMinutes;

  const AssessmentTimers({
    super.key,
    this.remainingTestTime,
    this.remainingSectionTime,
    this.sectionName,
    this.totalTestDurationMinutes = 60,
    this.sectionDurationMinutes = 15,
  });

  @override
  State<AssessmentTimers> createState() => _AssessmentTimersState();
}

class _AssessmentTimersState extends State<AssessmentTimers>
    with SingleTickerProviderStateMixin {
  Timer? _updateTimer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      context.read<AssessmentBloc>().add(const AssessmentTimerTick());

      final testCritical = widget.remainingTestTime != null &&
          widget.remainingTestTime!.inSeconds < 120;
      final sectionCritical = widget.remainingSectionTime != null &&
          widget.remainingSectionTime!.inSeconds < 120;
      if ((testCritical || sectionCritical) && !_shakeController.isAnimating) {
        _shakeController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTestSeconds = widget.totalTestDurationMinutes * 60;
    final totalSectionSeconds = widget.sectionDurationMinutes * 60;
    final testProgress = widget.remainingTestTime != null
        ? (widget.remainingTestTime!.inSeconds / totalTestSeconds)
            .clamp(0.0, 1.0)
        : 1.0;
    final sectionProgress = widget.remainingSectionTime != null
        ? (widget.remainingSectionTime!.inSeconds / totalSectionSeconds)
            .clamp(0.0, 1.0)
        : 1.0;

    final testCritical = widget.remainingTestTime != null &&
        widget.remainingTestTime!.inSeconds < 120;
    final sectionCritical = widget.remainingSectionTime != null &&
        widget.remainingSectionTime!.inSeconds < 120;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimerBar(
            label: 'Total',
            progress: testProgress,
            duration: widget.remainingTestTime,
            shakeAnimation: _shakeAnimation,
            isCritical: testCritical,
            clockIcon: Icons.timer_outlined,
          ),
          const SizedBox(height: 10),
          _TimerBar(
            label: widget.sectionName ?? 'Section',
            progress: sectionProgress,
            duration: widget.remainingSectionTime,
            shakeAnimation: _shakeAnimation,
            isCritical: sectionCritical,
            clockIcon: Icons.timer,
          ),
        ],
      ),
    );
  }
}

/// Bar where the clock+time chip rides the shrinking tip (moving rightleft).
class _TimerBar extends StatelessWidget {
  final String label;
  final double progress; // 1.0 = full time, 0.0 = expired
  final Duration? duration;
  final Animation<double> shakeAnimation;
  final bool isCritical;
  final IconData clockIcon;

  const _TimerBar({
    required this.label,
    required this.progress,
    required this.duration,
    required this.shakeAnimation,
    required this.isCritical,
    this.clockIcon = Icons.timer_outlined,
  });

  Color _color() {
    if (duration == null) return const Color(0xFF4CAF50);
    final s = duration!.inSeconds;
    if (s < 120) return const Color(0xFFF44336);
    if (s < 300) return const Color(0xFFFFC107);
    return const Color(0xFF4CAF50);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final timeStr = duration != null ? _fmt(duration!) : '--:--';
    const barH = 28.0;
    const chipW = 82.0;
    const radius = barH / 2;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final fillW = (progress * barWidth).clamp(chipW, barWidth);
              // Chip right-edge aligns with fill tip
              final chipLeft = (fillW - chipW).clamp(0.0, barWidth - chipW);

              return SizedBox(
                height: barH,
                child: Stack(
                  children: [
                    // Grey background track
                    Container(
                      height: barH,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                    // Colored fill (behind chip)
                    Container(
                      width: fillW,
                      height: barH,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                    // Clock chip at fill tip
                    Positioned(
                      left: chipLeft,
                      top: 0,
                      child: AnimatedBuilder(
                        animation: shakeAnimation,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(
                              isCritical ? shakeAnimation.value : 0.0, 0.0),
                          child: child,
                        ),
                        child: Container(
                          width: chipW,
                          height: barH,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(radius),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(clockIcon,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Compact variant (mobile sidebar)
class CompactAssessmentTimers extends StatefulWidget {
  final Duration? remainingTestTime;
  final Duration? remainingSectionTime;
  final int totalTestDurationMinutes;
  final int sectionDurationMinutes;

  const CompactAssessmentTimers({
    super.key,
    this.remainingTestTime,
    this.remainingSectionTime,
    this.totalTestDurationMinutes = 60,
    this.sectionDurationMinutes = 15,
  });

  @override
  State<CompactAssessmentTimers> createState() =>
      _CompactAssessmentTimersState();
}

class _CompactAssessmentTimersState extends State<CompactAssessmentTimers>
    with SingleTickerProviderStateMixin {
  Timer? _updateTimer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      context.read<AssessmentBloc>().add(const AssessmentTimerTick());
      final critical = (widget.remainingTestTime?.inSeconds ?? 999) < 120 ||
          (widget.remainingSectionTime?.inSeconds ?? 999) < 120;
      if (critical && !_shakeController.isAnimating) {
        _shakeController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTestSeconds = widget.totalTestDurationMinutes * 60;
    final totalSectionSeconds = widget.sectionDurationMinutes * 60;
    final testProgress = widget.remainingTestTime != null
        ? (widget.remainingTestTime!.inSeconds / totalTestSeconds)
            .clamp(0.0, 1.0)
        : 1.0;
    final sectionProgress = widget.remainingSectionTime != null
        ? (widget.remainingSectionTime!.inSeconds / totalSectionSeconds)
            .clamp(0.0, 1.0)
        : 1.0;
    final testCritical = (widget.remainingTestTime?.inSeconds ?? 999) < 120;
    final sectionCritical =
        (widget.remainingSectionTime?.inSeconds ?? 999) < 120;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimerBar(
            label: 'Total',
            progress: testProgress,
            duration: widget.remainingTestTime,
            shakeAnimation: _shakeAnimation,
            isCritical: testCritical,
            clockIcon: Icons.timer_outlined,
          ),
          const SizedBox(height: 10),
          _TimerBar(
            label: 'Section',
            progress: sectionProgress,
            duration: widget.remainingSectionTime,
            shakeAnimation: _shakeAnimation,
            isCritical: sectionCritical,
            clockIcon: Icons.timer,
          ),
        ],
      ),
    );
  }
}