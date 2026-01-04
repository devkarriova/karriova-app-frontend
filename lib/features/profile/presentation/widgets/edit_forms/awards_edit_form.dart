import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/profile_model.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import 'common/custom_text_field.dart';

/// Form for managing awards
class AwardsEditForm extends StatelessWidget {
  final ProfileModel profile;

  const AwardsEditForm({super.key, required this.profile});

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
                          'Awards & Honors',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add your achievements and recognition',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showAddAwardDialog(context),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      tooltip: 'Add Award',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Awards list
          if (profile.awards.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    'No awards added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddAwardDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first award'),
                  ),
                ],
              ),
            )
          else
            ...profile.awards.asMap().entries.map((entry) {
              final index = entry.key;
              final award = entry.value;
              return _AwardCard(
                award: award,
                onEdit: () => _showEditAwardDialog(context, index, award),
                onDelete: () => _confirmDelete(context, index, award.title),
              );
            }),
        ],
      ),
    );
  }

  void _showAddAwardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AwardFormDialog(
        onSave: (title, issuer, date, description) {
          context.read<ProfileBloc>().add(ProfileAwardAdded(
            title: title,
            issuer: issuer,
            date: date,
            description: description,
          ));
        },
      ),
    );
  }

  void _showEditAwardDialog(BuildContext context, int index, Award award) {
    showDialog(
      context: context,
      builder: (ctx) => _AwardFormDialog(
        award: award,
        onSave: (title, issuer, date, description) {
          context.read<ProfileBloc>().add(ProfileAwardUpdated(
            index: index,
            title: title,
            issuer: issuer,
            date: date,
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
        title: const Text('Delete Award'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ProfileAwardDeleted(index: index));
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

class _AwardCard extends StatelessWidget {
  final Award award;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AwardCard({
    required this.award,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');

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
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.emoji_events_outlined, color: Colors.orange),
        ),
        title: Text(
          award.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(award.issuer),
            Text(
              dateFormat.format(award.date),
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
            if (award.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                award.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ],
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

class _AwardFormDialog extends StatefulWidget {
  final Award? award;
  final void Function(String title, String issuer, DateTime date, String description) onSave;

  const _AwardFormDialog({this.award, required this.onSave});

  @override
  State<_AwardFormDialog> createState() => _AwardFormDialogState();
}

class _AwardFormDialogState extends State<_AwardFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _issuerController;
  late TextEditingController _descriptionController;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.award?.title ?? '');
    _issuerController = TextEditingController(text: widget.award?.issuer ?? '');
    _descriptionController = TextEditingController(text: widget.award?.description ?? '');
    _date = widget.award?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');
    return AlertDialog(
      title: Text(widget.award == null ? 'Add Award' : 'Edit Award'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Award Title',
                  hint: 'e.g., Employee of the Year',
                  controller: _titleController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Issuing Organization',
                  hint: 'e.g., Google',
                  controller: _issuerController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date Received', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(dateFormat.format(_date)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description (Optional)',
                  hint: 'Describe the award or achievement...',
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
                _issuerController.text.trim(),
                _date,
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
