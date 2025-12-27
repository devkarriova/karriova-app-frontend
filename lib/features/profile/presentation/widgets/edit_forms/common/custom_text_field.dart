import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

/// Minimalist custom text field for profile editing
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? suffix;
  final Widget? prefix;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.suffix,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            suffixIcon: suffix,
            prefixIcon: prefix,
          ),
        ),
      ],
    );
  }
}
