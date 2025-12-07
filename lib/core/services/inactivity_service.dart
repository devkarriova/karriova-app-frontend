import 'dart:async';
import 'package:flutter/material.dart';

/// Callback type for inactivity timeout
typedef InactivityCallback = void Function();

/// Service to track user inactivity and trigger auto-logout
class InactivityService {
  Timer? _inactivityTimer;
  InactivityCallback? _onInactivityTimeout;
  Duration _inactivityDuration;
  bool _isEnabled = false;

  InactivityService({
    Duration inactivityDuration = const Duration(minutes: 15),
  }) : _inactivityDuration = inactivityDuration;

  /// Enable inactivity tracking
  void enable({
    required InactivityCallback onTimeout,
    Duration? inactivityDuration,
  }) {
    _onInactivityTimeout = onTimeout;
    if (inactivityDuration != null) {
      _inactivityDuration = inactivityDuration;
    }
    _isEnabled = true;
    _startTimer();
  }

  /// Disable inactivity tracking
  void disable() {
    _isEnabled = false;
    _cancelTimer();
    _onInactivityTimeout = null;
  }

  /// Reset the inactivity timer (called on user activity)
  void resetTimer() {
    if (!_isEnabled) return;
    _cancelTimer();
    _startTimer();
  }

  /// Start the inactivity timer
  void _startTimer() {
    _inactivityTimer = Timer(_inactivityDuration, () {
      if (_onInactivityTimeout != null) {
        _onInactivityTimeout!();
      }
    });
  }

  /// Cancel the current timer
  void _cancelTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  /// Update inactivity duration
  void updateDuration(Duration duration) {
    _inactivityDuration = duration;
    if (_isEnabled) {
      resetTimer();
    }
  }

  /// Check if tracking is enabled
  bool get isEnabled => _isEnabled;

  /// Get current inactivity duration
  Duration get inactivityDuration => _inactivityDuration;

  /// Dispose the service
  void dispose() {
    _cancelTimer();
    _onInactivityTimeout = null;
    _isEnabled = false;
  }
}

/// Widget to detect user activity and reset inactivity timer
class InactivityDetector extends StatefulWidget {
  final Widget child;
  final InactivityService inactivityService;

  const InactivityDetector({
    Key? key,
    required this.child,
    required this.inactivityService,
  }) : super(key: key);

  @override
  State<InactivityDetector> createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends State<InactivityDetector> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserActivity(),
      onPointerMove: (_) => _onUserActivity(),
      onPointerUp: (_) => _onUserActivity(),
      child: widget.child,
    );
  }

  void _onUserActivity() {
    widget.inactivityService.resetTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
