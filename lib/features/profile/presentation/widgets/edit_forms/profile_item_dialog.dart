import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';

enum ProfileItemType {
  skill,
  language,
  certification,
  project,
  award,
  experience,
  education,
}

/// Generic dialog for adding or editing profile items
class ProfileItemDialog extends StatefulWidget {
  final ProfileItemType type;
  final Map<String, dynamic>? initialData;

  const ProfileItemDialog({
    super.key,
    required this.type,
    this.initialData,
  });

  @override
  State<ProfileItemDialog> createState() => _ProfileItemDialogState();
}

class _ProfileItemDialogState extends State<ProfileItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  int _rating = 3;
  String? _proficiency;
  bool _isCurrent = false;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _issueDate;
  DateTime? _expiryDate;
  final List<String> _technologies = [];
  final List<String> _achievements = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeData();
  }

  void _initializeControllers() {
    final fields = _getFieldsForType();
    for (final field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  void _initializeData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Initialize text controllers
      _controllers.forEach((key, controller) {
        if (data.containsKey(key)) {
          controller.text = data[key]?.toString() ?? '';
        }
      });

      // Initialize other fields
      if (data.containsKey('rating')) _rating = data['rating'] as int;
      if (data.containsKey('proficiency')) _proficiency = data['proficiency'] as String;
      if (data.containsKey('isCurrent') || data.containsKey('current')) {
        _isCurrent = (data['isCurrent'] ?? data['current']) as bool;
      }
      if (data.containsKey('startDate')) _startDate = data['startDate'] as DateTime?;
      if (data.containsKey('endDate')) _endDate = data['endDate'] as DateTime?;
      if (data.containsKey('issueDate')) _issueDate = data['issueDate'] as DateTime?;
      if (data.containsKey('expiryDate')) _expiryDate = data['expiryDate'] as DateTime?;
      if (data.containsKey('technologies')) {
        _technologies.addAll((data['technologies'] as List).cast<String>());
      }
      if (data.containsKey('achievements')) {
        _achievements.addAll((data['achievements'] as List).cast<String>());
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  List<String> _getFieldsForType() {
    switch (widget.type) {
      case ProfileItemType.skill:
        return ['name', 'yearsOfExperience'];
      case ProfileItemType.language:
        return ['name'];
      case ProfileItemType.certification:
        return ['name', 'issuer', 'credentialUrl'];
      case ProfileItemType.project:
        return ['name', 'description'];
      case ProfileItemType.award:
        return ['name', 'issuer'];
      case ProfileItemType.experience:
        return ['jobTitle', 'companyName', 'location', 'description', 'employmentType'];
      case ProfileItemType.education:
        return ['degree', 'institution', 'grade'];
    }
  }

  String _getTitle() {
    final isEdit = widget.initialData != null;
    final prefix = isEdit ? 'Edit' : 'Add';

    switch (widget.type) {
      case ProfileItemType.skill:
        return '$prefix Skill';
      case ProfileItemType.language:
        return '$prefix Language';
      case ProfileItemType.certification:
        return '$prefix Certification';
      case ProfileItemType.project:
        return '$prefix Project';
      case ProfileItemType.award:
        return '$prefix Award';
      case ProfileItemType.experience:
        return '$prefix Experience';
      case ProfileItemType.education:
        return '$prefix Education';
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ProfileItemType.skill:
        return Icons.code;
      case ProfileItemType.language:
        return Icons.language;
      case ProfileItemType.certification:
        return Icons.verified;
      case ProfileItemType.project:
        return Icons.folder;
      case ProfileItemType.award:
        return Icons.emoji_events;
      case ProfileItemType.experience:
        return Icons.work;
      case ProfileItemType.education:
        return Icons.school;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final result = <String, dynamic>{};

      // Add all controller values
      _controllers.forEach((key, controller) {
        final value = controller.text.trim();
        if (value.isNotEmpty) {
          // Try to parse as int for numeric fields
          if (key == 'yearsOfExperience') {
            result[key] = int.tryParse(value);
          } else {
            result[key] = value;
          }
        }
      });

      // Add type-specific fields
      switch (widget.type) {
        case ProfileItemType.skill:
          result['rating'] = _rating;
          break;
        case ProfileItemType.language:
          result['proficiency'] = _proficiency;
          break;
        case ProfileItemType.certification:
          result['issueDate'] = _issueDate;
          result['expiryDate'] = _expiryDate;
          break;
        case ProfileItemType.project:
          result['technologies'] = _technologies;
          break;
        case ProfileItemType.award:
          result['date'] = _issueDate;
          break;
        case ProfileItemType.experience:
          result['startDate'] = _startDate;
          result['endDate'] = _endDate;
          result['isCurrent'] = _isCurrent;
          break;
        case ProfileItemType.education:
          result['startDate'] = _startDate;
          result['endDate'] = _endDate;
          result['achievements'] = _achievements;
          break;
      }

      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildFields(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIcon(),
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _getTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.grey[600],
        ),
      ],
    );
  }

  List<Widget> _buildFields() {
    final widgets = <Widget>[];

    // Build text fields
    _controllers.forEach((key, controller) {
      widgets.add(_buildTextField(
        controller: controller,
        label: _formatLabel(key),
        hint: _getHint(key),
        required: _isRequired(key),
        maxLines: key.contains('description') ? 4 : 1,
      ));
      widgets.add(const SizedBox(height: 16));
    });

    // Add type-specific widgets
    switch (widget.type) {
      case ProfileItemType.skill:
        widgets.add(_buildRatingField());
        widgets.add(const SizedBox(height: 16));
        break;
      case ProfileItemType.language:
        widgets.add(_buildProficiencyField());
        widgets.add(const SizedBox(height: 16));
        break;
      case ProfileItemType.certification:
        widgets.add(_buildDateField('Issue Date', _issueDate, (date) {
          setState(() => _issueDate = date);
        }, required: true));
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildDateField('Expiry Date (Optional)', _expiryDate, (date) {
          setState(() => _expiryDate = date);
        }));
        widgets.add(const SizedBox(height: 16));
        break;
      case ProfileItemType.project:
        widgets.add(_buildTechnologiesField());
        widgets.add(const SizedBox(height: 16));
        break;
      case ProfileItemType.award:
        widgets.add(_buildDateField('Date Received', _issueDate, (date) {
          setState(() => _issueDate = date);
        }, required: true));
        widgets.add(const SizedBox(height: 16));
        break;
      case ProfileItemType.experience:
        widgets.add(_buildDateField('Start Date', _startDate, (date) {
          setState(() => _startDate = date);
        }, required: true));
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildCurrentCheckbox());
        widgets.add(const SizedBox(height: 16));
        if (!_isCurrent) {
          widgets.add(_buildDateField('End Date', _endDate, (date) {
            setState(() => _endDate = date);
          }));
          widgets.add(const SizedBox(height: 16));
        }
        break;
      case ProfileItemType.education:
        widgets.add(_buildDateField('Start Date', _startDate, (date) {
          setState(() => _startDate = date);
        }, required: true));
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildDateField('End Date', _endDate, (date) {
          setState(() => _endDate = date);
        }, required: true));
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildAchievementsField());
        widgets.add(const SizedBox(height: 16));
        break;
    }

    return widgets;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildRatingField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skill Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: AppColors.primary,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1;
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProficiencyField() {
    final proficiencies = ['Beginner', 'Intermediate', 'Professional', 'Native'];

    return DropdownButtonFormField<String>(
      value: _proficiency,
      decoration: InputDecoration(
        labelText: 'Proficiency Level',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: proficiencies.map((level) {
        return DropdownMenuItem(
          value: level,
          child: Text(level),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _proficiency = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a proficiency level';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? currentDate,
    Function(DateTime?) onDateSelected, {
    bool required = false,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: currentDate ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          currentDate != null
              ? DateFormat('MMM dd, yyyy').format(currentDate)
              : 'Select date',
          style: TextStyle(
            color: currentDate != null ? AppColors.textPrimary : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentCheckbox() {
    return CheckboxListTile(
      value: _isCurrent,
      onChanged: (value) {
        setState(() {
          _isCurrent = value ?? false;
          if (_isCurrent) {
            _endDate = null;
          }
        });
      },
      title: const Text('I currently work here'),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildTechnologiesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Technologies',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._technologies.map((tech) {
              return Chip(
                label: Text(tech),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _technologies.remove(tech);
                  });
                },
                backgroundColor: AppColors.primary.withOpacity(0.1),
                labelStyle: const TextStyle(color: AppColors.primary),
              );
            }),
            ActionChip(
              label: const Text('+ Add'),
              onPressed: () async {
                final tech = await _showAddItemDialog('Add Technology');
                if (tech != null && tech.isNotEmpty) {
                  setState(() {
                    _technologies.add(tech);
                  });
                }
              },
              backgroundColor: Colors.grey[200],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ..._achievements.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(entry.value)),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _achievements.removeAt(entry.key);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Achievement'),
          onPressed: () async {
            final achievement = await _showAddItemDialog('Add Achievement');
            if (achievement != null && achievement.isNotEmpty) {
              setState(() {
                _achievements.add(achievement);
              });
            }
          },
        ),
      ],
    );
  }

  Future<String?> _showAddItemDialog(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter text',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActions() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(100, 40),
            ),
            child: Text(
              widget.initialData != null ? 'Update' : 'Add',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String key) {
    final formatted = key.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    );
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  String? _getHint(String key) {
    switch (key) {
      case 'name':
        return 'e.g., Flutter, English, AWS Certification';
      case 'jobTitle':
        return 'e.g., Senior Developer';
      case 'companyName':
        return 'e.g., Tech Corp';
      case 'degree':
        return 'e.g., B.Sc in Computer Science';
      case 'institution':
        return 'e.g., MIT';
      default:
        return null;
    }
  }

  bool _isRequired(String key) {
    if (key == 'yearsOfExperience' || key == 'credentialUrl') return false;
    return true;
  }
}
