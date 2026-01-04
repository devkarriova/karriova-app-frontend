import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/profile_model.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import 'common/custom_text_field.dart';

/// Form for managing projects
class ProjectsEditForm extends StatelessWidget {
  final ProfileModel profile;

  const ProjectsEditForm({super.key, required this.profile});

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
                          'Projects',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Showcase your personal or professional projects',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showAddProjectDialog(context),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      tooltip: 'Add Project',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Projects list
          if (profile.projects.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Icon(Icons.folder_outlined, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    'No projects added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddProjectDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first project'),
                  ),
                ],
              ),
            )
          else
            ...profile.projects.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              return _ProjectCard(
                project: project,
                onEdit: () => _showEditProjectDialog(context, index, project),
                onDelete: () => _confirmDelete(context, index, project.name),
              );
            }),
        ],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ProjectFormDialog(
        onSave: (name, description, startDate, endDate, current, url, technologies) {
          context.read<ProfileBloc>().add(ProfileProjectAdded(
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate,
            current: current,
            url: url,
            technologies: technologies,
          ));
        },
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, int index, Project project) {
    showDialog(
      context: context,
      builder: (ctx) => _ProjectFormDialog(
        project: project,
        onSave: (name, description, startDate, endDate, current, url, technologies) {
          context.read<ProfileBloc>().add(ProfileProjectUpdated(
            index: index,
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate,
            current: current,
            url: url,
            technologies: technologies,
          ));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ProfileProjectDeleted(index: index));
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

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');
    final dateRange = project.current
        ? '${dateFormat.format(project.startDate)} - Present'
        : '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate!)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.folder_outlined, color: Colors.purple),
            ),
            title: Text(
              project.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateRange,
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
          if (project.technologies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: project.technologies.map((tech) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tech,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectFormDialog extends StatefulWidget {
  final Project? project;
  final void Function(String name, String description, DateTime startDate, DateTime? endDate, bool current, String url, List<String> technologies) onSave;

  const _ProjectFormDialog({this.project, required this.onSave});

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  late TextEditingController _technologiesController;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _current;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descriptionController = TextEditingController(text: widget.project?.description ?? '');
    _urlController = TextEditingController(text: widget.project?.url ?? '');
    _technologiesController = TextEditingController(
      text: widget.project?.technologies.join(', ') ?? '',
    );
    _startDate = widget.project?.startDate ?? DateTime.now();
    _endDate = widget.project?.endDate;
    _current = widget.project?.current ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      title: Text(widget.project == null ? 'Add Project' : 'Edit Project'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Project Name',
                  hint: 'e.g., E-commerce Platform',
                  controller: _nameController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  hint: 'Describe your project...',
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                  title: const Text('Currently working on this'),
                  value: _current,
                  onChanged: (v) => setState(() => _current = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Project URL (Optional)',
                  hint: 'https://github.com/...',
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Technologies (comma-separated)',
                  hint: 'e.g., Flutter, Firebase, Node.js',
                  controller: _technologiesController,
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
              final technologies = _technologiesController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              widget.onSave(
                _nameController.text.trim(),
                _descriptionController.text.trim(),
                _startDate,
                _current ? null : _endDate,
                _current,
                _urlController.text.trim(),
                technologies,
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
