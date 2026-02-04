import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/models/assessment_models.dart';

/// Question option card widget - displays a single selectable option
class QuestionOptionCard extends StatefulWidget {
  final OptionModel option;
  final bool isSelected;
  final VoidCallback onTap;

  const QuestionOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<QuestionOptionCard> createState() => _QuestionOptionCardState();
}

class _QuestionOptionCardState extends State<QuestionOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.08)
                : _isHovered
                    ? AppColors.primary.withOpacity(0.04)
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : _isHovered
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.border,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : _isHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
          ),
          child: Row(
            children: [
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primary
                        : _isHovered
                            ? AppColors.primary.withOpacity(0.5)
                            : AppColors.border,
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.white,
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.paddingMD),
              // Option text
              Expanded(
                child: Text(
                  widget.option.text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: widget.isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Question card widget - displays question text and options
class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final String? selectedOptionId;
  final Function(String optionId) onOptionSelected;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question text
        Text(
          question.text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        // Options
        ...question.options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
              child: QuestionOptionCard(
                option: option,
                isSelected: selectedOptionId == option.id,
                onTap: () => onOptionSelected(option.id),
              ),
            )),
      ],
    );
  }
}
