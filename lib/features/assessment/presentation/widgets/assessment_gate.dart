import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';
import '../pages/assessment_modal.dart';
import '../../../../core/di/injection.dart';

/// Widget that gates access to the app until assessment is complete
/// Wrap your main app content with this widget to enforce assessment completion
class AssessmentGate extends StatefulWidget {
  final Widget child;

  const AssessmentGate({
    super.key,
    required this.child,
  });

  @override
  State<AssessmentGate> createState() => _AssessmentGateState();
}

class _AssessmentGateState extends State<AssessmentGate> {
  late final AssessmentBloc _assessmentBloc;
  bool _hasCheckedStatus = false;
  bool _isAssessmentComplete = false;
  bool _isShowingModal = false;

  @override
  void initState() {
    super.initState();
    _assessmentBloc = getIt<AssessmentBloc>();

    // Check if assessment is already completed
    _assessmentBloc.add(const AssessmentStatusCheckRequested());
  }

  void _showAssessmentModal() {
    if (_isShowingModal) return;
    
    setState(() {
      _isShowingModal = true;
    });

    // Load the assessment first
    _assessmentBloc.add(const AssessmentLoadRequested());

    // Show the modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AssessmentModal.show(
        context,
        onComplete: () {
          setState(() {
            _isAssessmentComplete = true;
            _isShowingModal = false;
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _assessmentBloc,
      child: BlocListener<AssessmentBloc, AssessmentState>(
        listener: (context, state) {
          if (!_hasCheckedStatus) {
            _hasCheckedStatus = true;

            // TODO: FOR TESTING - Always show assessment modal
            // Comment out the completion check to always display assessment
            // if (state.hasCompletedAssessment) {
            //   setState(() {
            //     _isAssessmentComplete = true;
            //   });
            // } else {
            //   // Show assessment modal for first-time users
            //   _showAssessmentModal();
            // }

            // TESTING MODE: Always show assessment
            _showAssessmentModal();
          }
        },
        child: _isAssessmentComplete
            ? widget.child
            : _hasCheckedStatus
                ? widget.child // Show child while modal is displayed on top
                : const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
      ),
    );
  }
}

/// Extension to easily wrap any page with the assessment gate
extension AssessmentGateExtension on Widget {
  Widget withAssessmentGate() {
    return AssessmentGate(child: this);
  }
}
