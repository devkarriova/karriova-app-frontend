import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/profile_model.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import 'common/custom_text_field.dart';

/// Form for managing work experience
class ExperienceEditForm extends StatelessWidget {
  final ProfileModel profile;

  const ExperienceEditForm({super.key, required this.profile});

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
                          'Work Experience',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add your professional experience',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showAddExperienceDialog(context),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      tooltip: 'Add Experience',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Experience list
          if (profile.experience.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Icon(Icons.work_outline, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    'No experience added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddExperienceDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first experience'),
                  ),
                ],
              ),
            )
          else
            ...profile.experience.asMap().entries.map((entry) {
              final index = entry.key;
              final exp = entry.value;
              return _ExperienceCard(
                experience: exp,
                onEdit: () => _showEditExperienceDialog(context, index, exp),
                onDelete: () => _confirmDelete(context, index, exp.title),
              );
            }),
        ],
      ),
    );
  }

  void _showAddExperienceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ExperienceFormDialog(
        onSave: (title, company, location, startDate, endDate, current, description) {
          context.read<ProfileBloc>().add(ProfileExperienceAdded(
            title: title,
            company: company,
            companyId: '',
            location: location,
            startDate: startDate,
            endDate: endDate,
            current: current,
            description: description,
          ));
        },
      ),
    );
  }

  void _showEditExperienceDialog(BuildContext context, int index, Experience exp) {
    showDialog(
      context: context,
      builder: (ctx) => _ExperienceFormDialog(
        experience: exp,
        onSave: (title, company, location, startDate, endDate, current, description) {
          context.read<ProfileBloc>().add(ProfileExperienceUpdated(
            index: index,
            title: title,
            company: company,
            companyId: exp.companyId,
            location: location,
            startDate: startDate,
            endDate: endDate,
            current: current,
            description: description,
          ));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Experience'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ProfileExperienceDeleted(index: index));
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

class _ExperienceCard extends StatelessWidget {
  final Experience experience;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExperienceCard({
    required this.experience,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');
    final dateRange = experience.current
        ? '${dateFormat.format(experience.startDate)} - Present'
        : '${dateFormat.format(experience.startDate)} - ${dateFormat.format(experience.endDate!)}';

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
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.work_outline, color: AppColors.primary),
        ),
        title: Text(
          experience.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(experience.company),
            Text(
              '$dateRange • ${experience.location}',
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

class _ExperienceFormDialog extends StatefulWidget {
  final Experience? experience;
  final void Function(String title, String company, String location, DateTime startDate, DateTime? endDate, bool current, String description) onSave;

  const _ExperienceFormDialog({this.experience, required this.onSave});

  @override
  State<_ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<_ExperienceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _current;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.experience?.title ?? '');
    _companyController = TextEditingController(text: widget.experience?.company ?? '');
    _locationController = TextEditingController(text: widget.experience?.location ?? '');
    _descriptionController = TextEditingController(text: widget.experience?.description ?? '');
    _startDate = widget.experience?.startDate ?? DateTime.now();
    _endDate = widget.experience?.endDate;
    _current = widget.experience?.current ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
    final dateFormat = DateFormat('MMM yyyy');
    return AlertDialog(
      title: Text(widget.experience == null ? 'Add Experience' : 'Edit Experience'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Job Title',
                  hint: 'e.g., Software Engineer',
                  controller: _titleController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Company',
                  hint: 'e.g., Google',
                  controller: _companyController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Location',
                  hint: 'e.g., San Francisco, CA',
                  controller: _locationController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => _selectDate(context, true),
                            child: Text(dateFormat.format(_startDate)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (!_current)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _selectDate(context, false),
                              child: Text(_endDate != null ? dateFormat.format(_endDate!) : 'Select'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('I currently work here'),
                  value: _current,
                  onChanged: (v) => setState(() => _current = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  hint: 'Describe your responsibilities...',
                  controller: _descriptionController,
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
              widget.onSave(
                _titleController.text.trim(),
                _companyController.text.trim(),
                _locationController.text.trim(),
                _startDate,
                _current ? null : _endDate,
                _current,
                _descriptionController.text.trim(),
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
