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
          );
        },
      ),
    );
  }

  void _showAddSectionDialog(BuildContext context) {
    // TODO: Implement add section dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add section coming soon')),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final SectionModel section;
  final VoidCallback onTap;

  const _SectionCard({required this.section, required this.onTap});

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
          );
        },
      ),
    );
  }

  void _showAddDimensionDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add dimension coming soon')),
    );
  }
}

class _DimensionCard extends StatelessWidget {
  final DimensionModel dimension;
  final VoidCallback onTap;

  const _DimensionCard({required this.dimension, required this.onTap});

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
          );
        },
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add question coming soon')),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final int index;

  const _QuestionCard({required this.question, required this.index});

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
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$value coming soon')),
                    );
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
