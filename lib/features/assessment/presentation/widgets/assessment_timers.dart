import 'dart:async';
import 'package:flutter/material.dart';

/// Timer display component showing both overall test and section timers
class AssessmentTimers extends StatefulWidget {
  final Duration? remainingTestTime;
  final Duration? remainingSectionTime;
  final String? sectionName;

  const AssessmentTimers({
    super.key,
    this.remainingTestTime,
    this.remainingSectionTime,
    this.sectionName,
  });

  @override
  State<AssessmentTimers> createState() => _AssessmentTimersState();
}

class _AssessmentTimersState extends State<AssessmentTimers> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Update UI every second to show countdown
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {}); // Trigger rebuild to update timers
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _TimerDisplay(
              icon: Icons.timer_outlined,
              label: 'Total Time',
              duration: widget.remainingTestTime,
              isOverall: true,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _TimerDisplay(
              icon: Icons.timer,
              label: widget.sectionName != null
                  ? '${widget.sectionName} Time'
                  : 'Section Time',
              duration: widget.remainingSectionTime,
              isOverall: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual timer display widget
class _TimerDisplay extends StatelessWidget {
  final IconData icon;
  final String label;
  final Duration? duration;
  final bool isOverall;

  const _TimerDisplay({
    required this.icon,
    required this.label,
    required this.duration,
    required this.isOverall,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = duration != null
        ? _formatDuration(duration!)
        : '--:--';

    final color = _getTimerColor(duration);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  Color _getTimerColor(Duration? duration) {
    if (duration == null) {
      return Colors.grey;
    }

    final totalSeconds = duration.inSeconds;

    // Critical: < 2 minutes (120 seconds) = Red
    if (totalSeconds < 120) {
      return const Color(0xFFF44336); // Red
    }

    // Warning: 2-5 minutes (120-300 seconds) = Yellow/Amber
    if (totalSeconds < 300) {
      return const Color(0xFFFFC107); // Amber/Yellow
    }

    // Normal: > 5 minutes = Green
    return const Color(0xFF4CAF50); // Green
  }
}

/// Compact timer display for mobile/small screens
class CompactAssessmentTimers extends StatefulWidget {
  final Duration? remainingTestTime;
  final Duration? remainingSectionTime;

  const CompactAssessmentTimers({
    super.key,
    this.remainingTestTime,
    this.remainingSectionTime,
  });

  @override
  State<CompactAssessmentTimers> createState() =>
      _CompactAssessmentTimersState();
}

class _CompactAssessmentTimersState extends State<CompactAssessmentTimers> {
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CompactTimer(
            icon: Icons.timer_outlined,
            duration: widget.remainingTestTime,
            label: 'Total',
          ),
          _CompactTimer(
            icon: Icons.timer,
            duration: widget.remainingSectionTime,
            label: 'Section',
          ),
        ],
      ),
    );
  }
}

class _CompactTimer extends StatelessWidget {
  final IconData icon;
  final Duration? duration;
  final String label;

  const _CompactTimer({
    required this.icon,
    required this.duration,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = duration != null
        ? _formatDuration(duration!)
        : '--:--';

    final color = _getTimerColor(duration);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor(Duration? duration) {
    if (duration == null) return Colors.grey;

    final totalSeconds = duration.inSeconds;

    if (totalSeconds < 120) return const Color(0xFFF44336); // Red
    if (totalSeconds < 300) return const Color(0xFFFFC107); // Amber
    return const Color(0xFF4CAF50); // Green
  }
}
