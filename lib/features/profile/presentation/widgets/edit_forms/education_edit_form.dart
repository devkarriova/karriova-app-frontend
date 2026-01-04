import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/profile_model.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import 'common/custom_text_field.dart';

/// Form for managing education entries
class EducationEditForm extends StatelessWidget {
  final ProfileModel profile;

  const EducationEditForm({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with add button
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Education',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add your educational background',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showAddEducationDialog(context),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      tooltip: 'Add Education',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Education list
          if (profile.education.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Icon(Icons.school_outlined, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    'No education added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddEducationDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your education'),
                  ),
                ],
              ),
            )
          else
            ...profile.education.asMap().entries.map((entry) {
              final index = entry.key;
              final edu = entry.value;
              return _EducationCard(
                education: edu,
                onEdit: () => _showEditEducationDialog(context, index, edu),
                onDelete: () => _confirmDelete(context, index, edu.degree),
              );
            }),
        ],
      ),
    );
  }

  void _showAddEducationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _EducationFormDialog(
        onSave: (degree, institution, startDate, endDate, grade, achievements) {
          context.read<ProfileBloc>().add(ProfileEducationAdded(
            degree: degree,
            institution: institution,
            startDate: startDate,
            endDate: endDate,
            grade: grade,
            achievements: achievements,
          ));
        },
      ),
    );
  }

  void _showEditEducationDialog(BuildContext context, int index, Education edu) {
    showDialog(
      context: context,
      builder: (ctx) => _EducationFormDialog(
        education: edu,
        onSave: (degree, institution, startDate, endDate, grade, achievements) {
          context.read<ProfileBloc>().add(ProfileEducationUpdated(
            index: index,
            degree: degree,
            institution: institution,
            startDate: startDate,
            endDate: endDate,
            grade: grade,
            achievements: achievements,
          ));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, String degree) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Education'),
        content: Text('Are you sure you want to delete "$degree"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ProfileEducationDeleted(index: index));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final Education education;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EducationCard({
    required this.education,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy');
    final dateRange = '${dateFormat.format(education.startDate)} - ${dateFormat.format(education.endDate)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.school_outlined, color: AppColors.secondary),
        ),
        title: Text(
          education.degree,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(education.institution),
            Text(
              dateRange + (education.grade.isNotEmpty ? ' • ${education.grade}' : ''),
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _EducationFormDialog extends StatefulWidget {
  final Education? education;
  final void Function(String degree, String institution, DateTime startDate, DateTime endDate, String grade, List<String> achievements) onSave;

  const _EducationFormDialog({this.education, required this.onSave});

  @override
  State<_EducationFormDialog> createState() => _EducationFormDialogState();
}

class _EducationFormDialogState extends State<_EducationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _degreeController;
  late TextEditingController _institutionController;
  late TextEditingController _gradeController;
  late TextEditingController _achievementsController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _degreeController = TextEditingController(text: widget.education?.degree ?? '');
    _institutionController = TextEditingController(text: widget.education?.institution ?? '');
    _gradeController = TextEditingController(text: widget.education?.grade ?? '');
    _achievementsController = TextEditingController(
      text: widget.education?.achievements.join('\n') ?? '',
    );
    _startDate = widget.education?.startDate ?? DateTime.now();
    _endDate = widget.education?.endDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _institutionController.dispose();
    _gradeController.dispose();
    _achievementsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy');
    return AlertDialog(
      title: Text(widget.education == null ? 'Add Education' : 'Edit Education'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Degree',
                  hint: 'e.g., Bachelor of Science in Computer Science',
                  controller: _degreeController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Institution',
                  hint: 'e.g., Stanford University',
                  controller: _institutionController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => _selectDate(context, true),
                            child: Text(dateFormat.format(_startDate)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => _selectDate(context, false),
                            child: Text(dateFormat.format(_endDate)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Grade/GPA (Optional)',
                  hint: 'e.g., 3.8/4.0',
                  controller: _gradeController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Achievements (Optional)',
                  hint: 'One achievement per line',
                  controller: _achievementsController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final achievements = _achievementsController.text
                  .split('\n')
                  .where((s) => s.trim().isNotEmpty)
                  .toList();
              widget.onSave(
                _degreeController.text.trim(),
                _institutionController.text.trim(),
                _startDate,
                _endDate,
                _gradeController.text.trim(),
                achievements,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
