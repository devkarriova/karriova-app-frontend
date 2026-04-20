import 'package:flutter/material.dart';
import '../../domain/models/assessment_models.dart';
import 'question_indicator.dart';

/// Sidebar showing overview of questions in current subsection (parameter)
class QuestionOverviewSidebar extends StatelessWidget {
  final SectionModel currentSection;
  final String? currentParameterName; // subsection name, null for legacy sections
  final List<QuestionModel> sectionQuestions;
  final String currentQuestionId;
  final Set<String> attemptedQuestionIds;
  final Function(int) onQuestionTap;
  final VoidCallback? onNextParameter;
  final VoidCallback? onNextSection;
  final bool canProceedToNextParameter;
  final bool canProceedToNextSection;
  final int answeredCount;

  const QuestionOverviewSidebar({
    super.key,
    required this.currentSection,
    this.currentParameterName,
    required this.sectionQuestions,
    required this.currentQuestionId,
    required this.attemptedQuestionIds,
    required this.onQuestionTap,
    this.onNextParameter,
    this.onNextSection,
    this.canProceedToNextParameter = false,
    required this.canProceedToNextSection,
    required this.answeredCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          _buildSectionHeader(),

          // Question indicators grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildQuestionGrid(),
            ),
          ),

          // Progress counter
          _buildProgressCounter(),

          // Next section button
          _buildNextSectionButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2196F3), // Primary blue
            Color(0xFF1976D2), // Darker blue
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentParameterName != null ? currentSection.name : 'Section',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentParameterName ?? currentSection.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children: List.generate(
        sectionQuestions.length,
        (index) {
          final question = sectionQuestions[index];
          final isCurrentQuestion = question.id == currentQuestionId;
          final isAttempted = attemptedQuestionIds.contains(question.id);

          final state = isCurrentQuestion
              ? QuestionIndicatorState.current
              : isAttempted
                  ? QuestionIndicatorState.attempted
                  : QuestionIndicatorState.unattempted;

          return PulsingQuestionIndicator(
            questionNumber: index + 1,
            state: state,
            onTap: () => onQuestionTap(index),
            isEnabled: true,
          );
        },
      ),
    );
  }

  Widget _buildProgressCounter() {
    final totalQuestions = sectionQuestions.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions Completed',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: answeredCount / totalQuestions,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      answeredCount == totalQuestions
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$answeredCount / $totalQuestions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextSectionButton(BuildContext context) {
    final String label;
    final VoidCallback? callback;

    if (canProceedToNextParameter) {
      label = 'Next Subsection';
      callback = onNextParameter;
    } else if (canProceedToNextSection) {
      label = 'Next Section';
      callback = onNextSection;
    } else {
      label = 'Complete All Questions';
      callback = null;
    }

    final bool enabled = callback != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: callback,
        icon: Icon(enabled ? Icons.arrow_forward : Icons.lock),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: enabled ? Theme.of(context).primaryColor : Colors.grey,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

}

/// Compact sidebar for mobile (drawer or bottom sheet)
class CompactQuestionOverview extends StatelessWidget {
  final SectionModel currentSection;
  final String? currentParameterName;
  final List<QuestionModel> sectionQuestions;
  final String currentQuestionId;
  final Set<String> attemptedQuestionIds;
  final Function(int) onQuestionTap;
  final VoidCallback? onNextParameter;
  final VoidCallback? onNextSection;
  final bool canProceedToNextParameter;
  final bool canProceedToNextSection;
  final int answeredCount;

  const CompactQuestionOverview({
    super.key,
    required this.currentSection,
    this.currentParameterName,
    required this.sectionQuestions,
    required this.currentQuestionId,
    required this.attemptedQuestionIds,
    required this.onQuestionTap,
    this.onNextParameter,
    this.onNextSection,
    this.canProceedToNextParameter = false,
    required this.canProceedToNextSection,
    required this.answeredCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section / subsection title
          if (currentParameterName != null) ...[
            Text(
              currentSection.name,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            currentParameterName ?? currentSection.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Question grid (scrollable if needed)
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  sectionQuestions.length,
                  (index) {
                    final question = sectionQuestions[index];
                    final isCurrentQuestion = question.id == currentQuestionId;
                    final isAttempted =
                        attemptedQuestionIds.contains(question.id);

                    final state = isCurrentQuestion
                        ? QuestionIndicatorState.current
                        : isAttempted
                            ? QuestionIndicatorState.attempted
                            : QuestionIndicatorState.unattempted;

                    return QuestionIndicator(
                      questionNumber: index + 1,
                      state: state,
                      onTap: () {
                        onQuestionTap(index);
                        Navigator.pop(context); // Close drawer/sheet
                      },
                      isEnabled: true,
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '$answeredCount / ${sectionQuestions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Next subsection / section button
          Builder(builder: (context) {
            final String label;
            final VoidCallback? callback;

            if (canProceedToNextParameter) {
              label = 'Next Subsection';
              callback = onNextParameter;
            } else if (canProceedToNextSection) {
              label = 'Next Section';
              callback = onNextSection;
            } else {
              label = 'Complete All Questions';
              callback = null;
            }

            return ElevatedButton.icon(
              onPressed: callback,
              icon: Icon(callback != null ? Icons.arrow_forward : Icons.lock),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            );
          }),
        ],
      ),
    );
  }
}
