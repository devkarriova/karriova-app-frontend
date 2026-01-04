import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/profile_model.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';

/// Form for managing languages
class LanguagesEditForm extends StatefulWidget {
  final ProfileModel profile;

  const LanguagesEditForm({super.key, required this.profile});

  @override
  State<LanguagesEditForm> createState() => _LanguagesEditFormState();
}

class _LanguagesEditFormState extends State<LanguagesEditForm> {
  final _languageController = TextEditingController();
  String _selectedProficiency = 'Professional';

  final List<String> _proficiencyLevels = [
    'Native',
    'Fluent',
    'Professional',
    'Conversational',
    'Basic',
  ];

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  void _addLanguage() {
    final language = _languageController.text.trim();
    if (language.isNotEmpty) {
      context.read<ProfileBloc>().add(ProfileLanguageAdded(
        name: language,
        proficiencyLevel: _selectedProficiency,
      ));
      _languageController.clear();
    }
  }

  void _deleteLanguage(int index) {
    context.read<ProfileBloc>().add(ProfileLanguageDeleted(index: index));
  }

  void _editLanguage(int index, Language language) {
    showDialog(
      context: context,
      builder: (ctx) => _EditLanguageDialog(
        language: language,
        proficiencyLevels: _proficiencyLevels,
        onSave: (name, proficiency) {
          context.read<ProfileBloc>().add(ProfileLanguageUpdated(
            index: index,
            name: name,
            proficiencyLevel: proficiency,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final languages = state.profile?.languages ?? widget.profile.languages;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add language card
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
                    const Text(
                      'Languages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add languages you speak',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _languageController,
                            decoration: InputDecoration(
                              hintText: 'e.g., English, Spanish',
                              hintStyle: const TextStyle(color: AppColors.textTertiary),
                              filled: true,
                              fillColor: AppColors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            onFieldSubmitted: (_) => _addLanguage(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedProficiency,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            items: _proficiencyLevels.map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level, style: const TextStyle(fontSize: 14)),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedProficiency = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addLanguage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Languages list
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
                        const Text(
                          'Your Languages',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${languages.length} languages',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (languages.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.language_outlined, size: 48, color: AppColors.textTertiary),
                              SizedBox(height: 16),
                              Text(
                                'No languages added yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Add languages using the form above',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: languages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final lang = entry.value;
                          return _LanguageCard(
                            language: lang,
                            onEdit: () => _editLanguage(index, lang),
                            onDelete: () => _deleteLanguage(index),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final Language language;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LanguageCard({
    required this.language,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getProficiencyColor(String level) {
    switch (level) {
      case 'Native':
        return Colors.green;
      case 'Fluent':
        return Colors.blue;
      case 'Professional':
        return AppColors.primary;
      case 'Conversational':
        return Colors.orange;
      case 'Basic':
        return Colors.grey;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.language, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              language.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getProficiencyColor(language.proficiencyLevel).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getProficiencyColor(language.proficiencyLevel).withOpacity(0.3)),
            ),
            child: Text(
              language.proficiencyLevel,
              style: TextStyle(
                fontSize: 12,
                color: _getProficiencyColor(language.proficiencyLevel),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _EditLanguageDialog extends StatefulWidget {
  final Language language;
  final List<String> proficiencyLevels;
  final void Function(String name, String proficiency) onSave;

  const _EditLanguageDialog({
    required this.language,
    required this.proficiencyLevels,
    required this.onSave,
  });

  @override
  State<_EditLanguageDialog> createState() => _EditLanguageDialogState();
}

class _EditLanguageDialogState extends State<_EditLanguageDialog> {
  late TextEditingController _nameController;
  late String _selectedProficiency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.language.name);
    _selectedProficiency = widget.language.proficiencyLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedProficiency,
            decoration: const InputDecoration(
              labelText: 'Proficiency Level',
              border: OutlineInputBorder(),
            ),
            items: widget.proficiencyLevels.map((level) => DropdownMenuItem(
              value: level,
              child: Text(level),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedProficiency = value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              widget.onSave(name, _selectedProficiency);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
