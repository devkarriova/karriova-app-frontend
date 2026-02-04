import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection.dart';
import '../../../assessment/data/datasources/assessment_remote_datasource.dart';
import '../../../assessment/domain/models/assessment_models.dart';

/// Admin tab for managing assessment configuration
/// Uses drill-down navigation: Sections → Dimensions → Questions
class AssessmentManagementTab extends StatefulWidget {
  const AssessmentManagementTab({super.key});

  @override
  State<AssessmentManagementTab> createState() => _AssessmentManagementTabState();
}

class _AssessmentManagementTabState extends State<AssessmentManagementTab> {
  // Navigation state
  SectionModel? _selectedSection;
  DimensionModel? _selectedDimension;

  // Data
  List<SectionModel> _sections = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  Future<void> _loadAssessment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = getIt<AssessmentRemoteDataSource>();
      final assessment = await datasource.getActiveAssessment();
      setState(() {
        _sections = assessment.sections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateBack() {
    setState(() {
      if (_selectedDimension != null) {
        _selectedDimension = null;
      } else if (_selectedSection != null) {
        _selectedSection = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        _buildBreadcrumb(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load assessment',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadAssessment,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    final items = <_BreadcrumbItem>[
      _BreadcrumbItem('Sections', () => setState(() {
        _selectedSection = null;
        _selectedDimension = null;
      })),
    ];

    if (_selectedSection != null) {
      items.add(_BreadcrumbItem(_selectedSection!.name, () => setState(() {
        _selectedDimension = null;
      })));
    }

    if (_selectedDimension != null) {
      items.add(_BreadcrumbItem(_selectedDimension!.name, null));
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          if (_selectedSection != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: _navigateBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: items.asMap().entries.map((entry) {
                  final isLast = entry.key == items.length - 1;
                  final item = entry.value;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entry.key > 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                        ),
                      GestureDetector(
                        onTap: item.onTap,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                            color: isLast ? AppColors.textPrimary : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedDimension != null) {
      return _QuestionsView(
        dimension: _selectedDimension!,
        onRefresh: _loadAssessment,
      );
    }

    if (_selectedSection != null) {
      return _DimensionsView(
        section: _selectedSection!,
        onDimensionTap: (dim) => setState(() => _selectedDimension = dim),
        onRefresh: _loadAssessment,
      );
    }

    return _SectionsView(
      sections: _sections,
      onSectionTap: (section) => setState(() => _selectedSection = section),
      onRefresh: _loadAssessment,
    );
  }
}

class _BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  _BreadcrumbItem(this.label, this.onTap);
}

/// Sections list view
class _SectionsView extends StatelessWidget {
  final List<SectionModel> sections;
  final Function(SectionModel) onSectionTap;
  final VoidCallback onRefresh;

  const _SectionsView({
    required this.sections,
    required this.onSectionTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return _EmptyState(
        icon: Icons.folder_outlined,
        title: 'No sections yet',
        subtitle: 'Create your first assessment section',
        onAdd: () => _showAddSectionDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        itemCount: sections.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          if (index == sections.length) {
            return _AddCard(
              label: 'Add Section',
              onTap: () => _showAddSectionDialog(context),
            );
          }
          final section = sections[index];
          return _SectionCard(
            section: section,
            onTap: () => onSectionTap(section),
            onEdit: () => _showEditSectionDialog(context, section),
            onDelete: () => _showDeleteSectionDialog(context, section),
          );
        },
      ),
    );
  }

  void _showAddSectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AddSectionDialog(onCreated: onRefresh),
    );
  }

  void _showEditSectionDialog(BuildContext context, SectionModel section) {
    showDialog(
      context: context,
      builder: (ctx) => _EditSectionDialog(section: section, onUpdated: onRefresh),
    );
  }

  void _showDeleteSectionDialog(BuildContext context, SectionModel section) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(
        title: 'Delete Section',
        message: 'Are you sure you want to delete "${section.name}"? This will also delete all dimensions and questions inside it.',
        onConfirm: () async {
          final datasource = getIt<AssessmentRemoteDataSource>();
          await datasource.deleteSection(section.id);
          onRefresh();
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final SectionModel section;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _SectionCard({required this.section, required this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dimensionCount = section.dimensions.length;
    final questionCount = section.dimensions.fold<int>(
      0, (sum, d) => sum + d.questions.length,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dimensionCount dimensions • $questionCount questions',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: onEdit,
                  tooltip: 'Edit section',
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red.shade400,
                  onPressed: onDelete,
                  tooltip: 'Delete section',
                ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dimensions list view
class _DimensionsView extends StatelessWidget {
  final SectionModel section;
  final Function(DimensionModel) onDimensionTap;
  final VoidCallback onRefresh;

  const _DimensionsView({
    required this.section,
    required this.onDimensionTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (section.dimensions.isEmpty) {
      return _EmptyState(
        icon: Icons.swap_horiz,
        title: 'No dimensions yet',
        subtitle: 'Add dimensions to measure personality traits',
        onAdd: () => _showAddDimensionDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        itemCount: section.dimensions.length + 1,
        itemBuilder: (context, index) {
          if (index == section.dimensions.length) {
            return _AddCard(
              label: 'Add Dimension',
              onTap: () => _showAddDimensionDialog(context),
            );
          }
          final dimension = section.dimensions[index];
          return _DimensionCard(
            dimension: dimension,
            onTap: () => onDimensionTap(dimension),
            onEdit: () => _showEditDimensionDialog(context, dimension),
            onDelete: () => _showDeleteDimensionDialog(context, dimension),
          );
        },
      ),
    );
  }

  void _showAddDimensionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AddDimensionDialog(
        sectionId: section.id,
        onCreated: onRefresh,
      ),
    );
  }

  void _showEditDimensionDialog(BuildContext context, DimensionModel dimension) {
    showDialog(
      context: context,
      builder: (ctx) => _EditDimensionDialog(dimension: dimension, onUpdated: onRefresh),
    );
  }

  void _showDeleteDimensionDialog(BuildContext context, DimensionModel dimension) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(
        title: 'Delete Dimension',
        message: 'Are you sure you want to delete "${dimension.name}"? This will also delete all questions inside it.',
        onConfirm: () async {
          final datasource = getIt<AssessmentRemoteDataSource>();
          await datasource.deleteDimension(dimension.id);
          onRefresh();
        },
      ),
    );
  }
}

class _DimensionCard extends StatelessWidget {
  final DimensionModel dimension;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DimensionCard({required this.dimension, required this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.swap_horiz, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dimension.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dimension.questions.length} questions',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: onEdit,
                      tooltip: 'Edit dimension',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red.shade400,
                      onPressed: onDelete,
                      tooltip: 'Delete dimension',
                    ),
                  const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: 12),
              // Pole labels
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dimension.poleALabel,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward, size: 14, color: AppColors.textTertiary),
                    Row(
                      children: [
                        Text(
                          dimension.poleBLabel,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Questions list view
class _QuestionsView extends StatelessWidget {
  final DimensionModel dimension;
  final VoidCallback onRefresh;

  const _QuestionsView({
    required this.dimension,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (dimension.questions.isEmpty) {
      return _EmptyState(
        icon: Icons.help_outline,
        title: 'No questions yet',
        subtitle: 'Add questions for this dimension',
        onAdd: () => _showAddQuestionDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        itemCount: dimension.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == dimension.questions.length) {
            return _AddCard(
              label: 'Add Question',
              onTap: () => _showAddQuestionDialog(context),
            );
          }
          final question = dimension.questions[index];
          return _QuestionCard(
            question: question,
            index: index + 1,
            onDelete: () => _showDeleteQuestionDialog(context, question),
          );
        },
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AddQuestionDialog(
        dimensionId: dimension.id,
        onCreated: onRefresh,
      ),
    );
  }

  void _showDeleteQuestionDialog(BuildContext context, QuestionModel question) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(
        title: 'Delete Question',
        message: 'Are you sure you want to delete this question?',
        onConfirm: () async {
          final datasource = getIt<AssessmentRemoteDataSource>();
          await datasource.deleteQuestion(question.id);
          onRefresh();
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int index;
  final VoidCallback? onDelete;

  const _QuestionCard({required this.question, required this.index, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (value) {
                    if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Options
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: question.options.map((opt) => _OptionChip(option: opt)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final OptionModel option;

  const _OptionChip({required this.option});

  @override
  Widget build(BuildContext context) {
    final isLowScore = option.score <= 2;
    final isHighScore = option.score >= 4;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLowScore
            ? AppColors.primary.withOpacity(0.08)
            : isHighScore
                ? AppColors.secondary.withOpacity(0.08)
                : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLowScore
              ? AppColors.primary.withOpacity(0.3)
              : isHighScore
                  ? AppColors.secondary.withOpacity(0.3)
                  : AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            option.text,
            style: TextStyle(
              fontSize: 12,
              color: isLowScore
                  ? AppColors.primary
                  : isHighScore
                      ? AppColors.secondary
                      : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${option.score}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add card widget
class _AddCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddCard({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      color: AppColors.primary.withOpacity(0.02),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primary.withOpacity(0.7), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// ADD DIALOGS
// ========================================

/// Dialog for adding a new section
class _AddSectionDialog extends StatefulWidget {
  final VoidCallback onCreated;

  const _AddSectionDialog({required this.onCreated});

  @override
  State<_AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<_AddSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = getIt<AssessmentRemoteDataSource>();
      await datasource.createSection(
        _nameController.text.trim(),
        _descController.text.trim(),
      );
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.category, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Section',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Section Name',
                  hintText: 'e.g., Personality Assessment',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of this section',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding a new dimension
class _AddDimensionDialog extends StatefulWidget {
  final String sectionId;
  final VoidCallback onCreated;

  const _AddDimensionDialog({required this.sectionId, required this.onCreated});

  @override
  State<_AddDimensionDialog> createState() => _AddDimensionDialogState();
}

class _AddDimensionDialogState extends State<_AddDimensionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _poleAController = TextEditingController(text: 'Low');
  final _poleBController = TextEditingController(text: 'High');
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _poleAController.dispose();
    _poleBController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = getIt<AssessmentRemoteDataSource>();
      await datasource.createDimension(
        widget.sectionId,
        _nameController.text.trim(),
        _descController.text.trim(),
        poleALabel: _poleAController.text.trim(),
        poleBLabel: _poleBController.text.trim(),
      );
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.swap_horiz, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Dimension',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Dimension Name',
                  hintText: 'e.g., Workstyle, Leadership',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What this dimension measures',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              const Text(
                'Pole Labels (Spectrum Endpoints)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Define the two opposite ends of this personality trait',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _poleAController,
                      decoration: InputDecoration(
                        labelText: 'Pole A (Low end)',
                        hintText: 'e.g., Structured',
                        border: const OutlineInputBorder(),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          width: 12, height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward, color: AppColors.textTertiary),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _poleBController,
                      decoration: InputDecoration(
                        labelText: 'Pole B (High end)',
                        hintText: 'e.g., Flexible',
                        border: const OutlineInputBorder(),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          width: 12, height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding a new question with options
class _AddQuestionDialog extends StatefulWidget {
  final String dimensionId;
  final VoidCallback onCreated;

  const _AddQuestionDialog({required this.dimensionId, required this.onCreated});

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<_OptionEntry> _options = [
    _OptionEntry(TextEditingController(), 1),
    _OptionEntry(TextEditingController(), 2),
    _OptionEntry(TextEditingController(), 3),
    _OptionEntry(TextEditingController(), 4),
  ];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _questionController.dispose();
    for (final opt in _options) {
      opt.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate options
    final validOptions = _options.where((o) => o.controller.text.trim().isNotEmpty).toList();
    if (validOptions.length < 2) {
      setState(() => _error = 'At least 2 options are required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = getIt<AssessmentRemoteDataSource>();
      await datasource.createQuestion(
        widget.dimensionId,
        _questionController.text.trim(),
        validOptions.map((o) => OptionInput(text: o.controller.text.trim(), score: o.score)).toList(),
      );
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.help_outline, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Question',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  hintText: 'Enter the question...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              const Text('Answer Options (with scores)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final opt = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: DropdownButtonFormField<int>(
                                value: opt.score,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                                items: [1, 2, 3, 4, 5].map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(),
                                onChanged: (v) => setState(() => _options[index].score = v ?? 1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: opt.controller,
                                decoration: InputDecoration(
                                  hintText: 'Option ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionEntry {
  final TextEditingController controller;
  int score;

  _OptionEntry(this.controller, this.score);
}

// ========================================
// EDIT DIALOGS
// ========================================

/// Dialog for editing a section
class _EditSectionDialog extends StatefulWidget {
  final SectionModel section;
  final VoidCallback onUpdated;

  const _EditSectionDialog({required this.section, required this.onUpdated});

  @override
  State<_EditSectionDialog> createState() => _EditSectionDialogState();
}

class _EditSectionDialogState extends State<_EditSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.section.name);
    _descController = TextEditingController(text: widget.section.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = getIt<AssessmentRemoteDataSource>();
      await datasource.updateSection(
        widget.section.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
      );
      widget.onUpdated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Section',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Section Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 40),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for editing a dimension (including pole labels)
class _EditDimensionDialog extends StatefulWidget {
  final DimensionModel dimension;
  final VoidCallback onUpdated;

  const _EditDimensionDialog({required this.dimension, required this.onUpdated});

  @override
  State<_EditDimensionDialog> createState() => _EditDimensionDialogState();
}

class _EditDimensionDialogState extends State<_EditDimensionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _poleAController;
  late final TextEditingController _poleBController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dimension.name);
    _descController = TextEditingController(text: widget.dimension.description);
    _poleAController = TextEditingController(text: widget.dimension.poleALabel);
    _poleBController = TextEditingController(text: widget.dimension.poleBLabel);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _poleAController.dispose();
    _poleBController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = getIt<AssessmentRemoteDataSource>();
      await datasource.updateDimension(
        widget.dimension.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        poleALabel: _poleAController.text.trim(),
        poleBLabel: _poleBController.text.trim(),
      );
      widget.onUpdated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Dimension',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Dimension Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              const Text(
                'Pole Labels (Spectrum Endpoints)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Define the two opposite ends of this personality trait',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _poleAController,
                      decoration: InputDecoration(
                        labelText: 'Pole A (Low end)',
                        border: const OutlineInputBorder(),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          width: 12, height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward, color: AppColors.textTertiary),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _poleBController,
                      decoration: InputDecoration(
                        labelText: 'Pole B (High end)',
                        border: const OutlineInputBorder(),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          width: 12, height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 40),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// DELETE CONFIRMATION DIALOG
// ========================================

class _DeleteConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final Future<void> Function() onConfirm;

  const _DeleteConfirmDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _isLoading = false;
  String? _error;

  Future<void> _handleDelete() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.message,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 40),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
