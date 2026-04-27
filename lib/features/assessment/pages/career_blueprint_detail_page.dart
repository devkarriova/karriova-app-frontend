import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/theme/app_typography.dart';
import 'package:karriova_app/core/config/app_config.dart';
import 'package:karriova_app/core/di/injection.dart';
import 'package:karriova_app/features/assessment/models/career_blueprint_model.dart';
import 'package:karriova_app/features/assessment/services/blueprint_api_service.dart';
import 'package:karriova_app/features/assessment/widgets/blueprint_charts_widget.dart';

/// Blueprint Detail Page - Full 14-section blueprint with expandable cards
class CareerBlueprintDetailPage extends StatefulWidget {
  final String blueprintId;
  final String careerName;
  final String attemptId;
  final Dio? dio;
  final String? apiBaseUrl;

  const CareerBlueprintDetailPage({
    required this.blueprintId,
    required this.careerName,
    required this.attemptId,
    this.dio,
    this.apiBaseUrl,
    Key? key,
  }) : super(key: key);

  @override
  _CareerBlueprintDetailPageState createState() =>
      _CareerBlueprintDetailPageState();
}

class _CareerBlueprintDetailPageState extends State<CareerBlueprintDetailPage> {
  bool _isLoading = true;
  CareerBlueprint? _blueprint;
  Set<String> _expandedSections = {};
  String? _errorMessage;
  late BlueprintApiService _apiService;

  @override
  void initState() {
    super.initState();
    // Initialize API service
    final dio = widget.dio ?? getIt<Dio>();
    final baseUrl = widget.apiBaseUrl ?? AppConfig.apiBaseUrl;
    _apiService = BlueprintApiService(dio: dio, baseUrl: baseUrl);
    
    _loadBlueprint();
  }

  Future<void> _loadBlueprint() async {
    try {
      final blueprint = await _apiService.getBlueprintDetail(widget.blueprintId);
      final ordered = finalSections(blueprint);
      setState(() {
        _blueprint = blueprint;
        _expandedSections = {};
        // Auto-expand first 2 sections
        if (ordered.isNotEmpty) {
          _expandedSections.add(ordered[0].id);
          if (ordered.length > 1) {
            _expandedSections.add(ordered[1].id);
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load blueprint: $e';
      });
    }
  }

  void _toggleSection(String sectionId) {
    setState(() {
      if (_expandedSections.contains(sectionId)) {
        _expandedSections.remove(sectionId);
      } else {
        _expandedSections.add(sectionId);
      }
    });
  }

  void _selectCareer() async {
    try {
      await _apiService.selectBlueprint(
        widget.blueprintId,
        widget.attemptId,
      );
      
      // Update UI to show selected state
      setState(() {
        if (_blueprint != null) {
          _blueprint = _blueprint!.copyWith(status: 'selected');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Career selection locked!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Blueprint'),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadBlueprint,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_blueprint == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Blueprint'),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const Center(
          child: Text('No blueprint data'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.careerName),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with stats
            _buildHeader(_blueprint!),

            // Charts
            if (_blueprint!.charts != null)
              BlueprintChartsWidget(
                chartData: _blueprint!.charts,
                careerName: _blueprint!.careerName,
              ),

            // Keep a single ordered list to prevent tile jumping/re-ordering.
            ...finalSections(_blueprint!).map((section) {
              final isExpanded = _expandedSections.contains(section.id);
              return _buildSection(section, isExpanded);
            }).toList(),

            // Selection button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: !_blueprint!.isSelected ? _selectCareer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blueprint!.isSelected
                        ? AppColors.success
                        : AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _blueprint!.isSelected
                        ? '✓ Career Selected'
                        : 'Select This Career',
                    style: AppTypography.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BlueprintSection> finalSections(CareerBlueprint blueprint) {
    final sections = List<BlueprintSection>.from(blueprint.sections);
    sections.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sections;
  }

  Widget _buildHeader(CareerBlueprint blueprint) {
    return Container(
      color: AppColors.lightBlue,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fit score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${blueprint.fitScore.toStringAsFixed(1)} Match',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // category
          if (blueprint.careerCategory != null)
            Text(
              blueprint.careerCategory!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 17,
              ),
            ),

          const SizedBox(height: 24),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Difficulty', blueprint.difficultyLevel),
              _buildStatItem('Fit Level', blueprint.confidenceLevel),
              _buildStatItem('Sections', '${blueprint.sections.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BlueprintSection section, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.primary.withOpacity(0.35) : AppColors.border,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _toggleSection(section.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _getIconForType(section.sectionType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        if (section.subtitle != null && section.subtitle!.isNotEmpty)
                          Text(
                            section.subtitle!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(section.content).map((card) => _buildCard(card, section.sectionType)).toList(),
                  if (section.warnings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...(section.warnings).map((warning) => _buildWarning(warning)).toList(),
                  ],
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BlueprintCardContent card, String sectionType) {
    Color accent;
    Color bg;
    switch (sectionType) {
      case 'warning':
        accent = const Color(0xFFDC2626);
        bg = const Color(0xFFFEE2E2);
        break;
      case 'timeline':
        accent = const Color(0xFF059669);
        bg = const Color(0xFFD1FAE5);
        break;
      case 'data':
        accent = const Color(0xFFD97706);
        bg = const Color(0xFFFFEDD5);
        break;
      case 'action':
        accent = const Color(0xFF4F46E5);
        bg = const Color(0xFFE0E7FF);
        break;
      default:
        accent = AppColors.primary;
        bg = AppColors.lightBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.title.isNotEmpty)
            Text(
              card.title,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          if (card.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              card.description,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
          if (card.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...card.items
                .map((item) => _buildListItem(item))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildListItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              item,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning(BlueprintWarning warning) {
    Color _severityColor() {
      switch (warning.severity.toLowerCase()) {
        case 'high':
          return AppColors.error;
        case 'medium':
          return const Color(0xFFF59E0B);
        default:
          return const Color(0xFF10B981);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _severityColor().withOpacity(0.1),
        border: Border(left: BorderSide(color: _severityColor(), width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 16, color: _severityColor()),
              const SizedBox(width: 8),
              Text(
                warning.title,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _severityColor(),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            warning.description,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIconForType(String type) {
    switch (type) {
      case 'insight':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.lightbulb_outline,
              size: 16, color: AppColors.primary),
        );
      case 'action':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFC7D2FE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.play_arrow,
              size: 16, color: Color(0xFF4F46E5)),
        );
      case 'warning':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.warning_outlined,
              size: 16, color: Color(0xFFDC2626)),
        );
      case 'data':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFED7AA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.trending_up,
              size: 16, color: Color(0xFFD97706)),
        );
      case 'timeline':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFA7F3D0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.timeline,
              size: 16, color: Color(0xFF059669)),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description_outlined, size: 16),
        );
    }
  }
}
