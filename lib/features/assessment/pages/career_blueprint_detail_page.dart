import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/theme/app_typography.dart';
import 'package:karriova_app/core/config/app_config.dart';
import 'package:karriova_app/core/di/injection.dart';
import 'package:karriova_app/core/utils/web_file_utils_stub.dart'
  if (dart.library.html) 'package:karriova_app/core/utils/web_file_utils_web.dart';
import 'package:karriova_app/features/assessment/models/career_blueprint_model.dart';
import 'package:karriova_app/features/assessment/data/repositories/assessment_repository_impl.dart';
import 'package:karriova_app/features/assessment/services/blueprint_api_service.dart';
import 'package:karriova_app/features/assessment/widgets/blueprint_loading_widget.dart';
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
  bool _isSelecting = false;
  bool _isDownloadingReport = false;
  CareerBlueprint? _blueprint;
  String? _errorMessage;
  late BlueprintApiService _apiService;
  late AssessmentRepository _assessmentRepository;

  @override
  void initState() {
    super.initState();
    // Initialize API service
    final dio = widget.dio ?? getIt<Dio>();
    final baseUrl = widget.apiBaseUrl ?? AppConfig.apiBaseUrl;
    _apiService = BlueprintApiService(dio: dio, baseUrl: baseUrl);
    _assessmentRepository = getIt<AssessmentRepository>();
    
    _loadBlueprint();
  }

  Future<void> _downloadKitReport() async {
    final selectedType = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Download KIT Short Report'),
                subtitle: const Text('Concise summary with key charts'),
                onTap: () => Navigator.of(context).pop('short'),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Download KIT Detailed Report'),
                subtitle: const Text('Full profile with expanded chart sections'),
                onTap: () => Navigator.of(context).pop('detailed'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedType == null) {
      return;
    }

    setState(() {
      _isDownloadingReport = true;
    });

    final result = await _assessmentRepository.downloadKitReportPdf(
      type: selectedType,
      blueprintId: widget.blueprintId,
    );
    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isDownloadingReport = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (file) {
        if (kIsWeb) {
          downloadBytesOnWeb(file.bytes, 'application/pdf', file.fileName);
        }

        setState(() {
          _isDownloadingReport = false;
        });

        final message = kIsWeb
            ? 'KIT report download started.'
            : 'KIT report is ready. Automatic file download is currently available on web.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      },
    );
  }

  Future<void> _loadBlueprint() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final blueprint = await _apiService.getBlueprintDetail(widget.blueprintId);
      setState(() {
        _blueprint = blueprint;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load blueprint: $e';
      });
    }
  }

  void _selectCareer() async {
    setState(() {
      _isSelecting = true;
    });

    try {
      await _apiService.selectBlueprint(
        widget.blueprintId,
        widget.attemptId,
      );

      if (!mounted) return;
      
      // Update UI to show selected state
      setState(() {
        _isSelecting = false;
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
      if (!mounted) return;

      setState(() {
        _isSelecting = false;
      });
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
        backgroundColor: AppColors.background,
        body: const BlueprintLoadingWidget(
          variant: BlueprintLoadingVariant.detail,
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
        actions: [
          if (_isDownloadingReport)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _downloadKitReport,
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download KIT Report',
            ),
        ],
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

            ..._buildSectionLayout(finalSections(_blueprint!)),

            // Selection button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isDownloadingReport ? null : _downloadKitReport,
                      icon: _isDownloadingReport
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded),
                      label: Text(
                        _isDownloadingReport
                            ? 'Generating KIT report...'
                            : 'Download KIT Report',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (!_blueprint!.isSelected && !_isSelecting) ? _selectCareer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blueprint!.isSelected
                            ? AppColors.success
                            : AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSelecting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Locking your career choice...',
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Text(
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
                ],
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

  List<Widget> _buildSectionLayout(List<BlueprintSection> orderedSections) {
    final selectedGridSections = orderedSections.where(_shouldRenderInGrid).toList();
    final topGridSections = selectedGridSections.isNotEmpty
      ? selectedGridSections
      : orderedSections.take(3).toList();
    final remainingSections = orderedSections
      .where((section) => !topGridSections.contains(section))
      .toList();

    final widgets = <Widget>[];

    if (topGridSections.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 2 : 1;
              const gap = 12.0;
              final cardWidth =
                  columns == 1 ? constraints.maxWidth : (constraints.maxWidth - gap) / 2;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: topGridSections
                    .map(
                      (section) => SizedBox(
                        width: cardWidth,
                        child: _buildSection(section, margin: EdgeInsets.zero),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      );
    }

    widgets.addAll(remainingSections.map(_buildSection));
    return widgets;
  }

  bool _shouldRenderInGrid(BlueprintSection section) {
    final title = _normalized(section.title);
    return title.contains('why this career fits') ||
        title.contains('your unique journey') ||
        title.contains('detailed roadmap');
  }

  Widget _buildHeader(CareerBlueprint blueprint) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9F5FF), Color(0xFFF5F8FF)],
        ),
      ),
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

          Text(
            blueprint.careerName,
            style: AppTypography.heading3.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // category
          if (blueprint.careerCategory != null && blueprint.careerCategory!.isNotEmpty)
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

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip('Personalized Plan', const Icon(Icons.auto_awesome, size: 14)),
              _buildMetaChip('14 Action Sections', const Icon(Icons.view_agenda_outlined, size: 14)),
              _buildMetaChip('Live Growth Insights', const Icon(Icons.trending_up, size: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(String text, Icon icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
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

  Widget _buildSection(
    BlueprintSection section, {
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    final cards = _effectiveCardsForSection(section);

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
            ],
          ),
          if (cards.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCardGrid(cards, section),
          ],
          if (section.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...section.warnings.map((warning) => _buildWarning(warning)),
          ],
        ],
      ),
    );
  }

  List<BlueprintCardContent> _effectiveCardsForSection(BlueprintSection section) {
    final cards = section.content.where((card) {
      final duplicateTitle = _isDuplicateCardTitle(card, section);
      final duplicateDescription = _isDuplicateCardDescription(card, section);
      final hasItems = card.items.isNotEmpty;
      return !(duplicateTitle && duplicateDescription && !hasItems);
    }).toList();

    final hasOverview = section.description.trim().isNotEmpty &&
        !cards.any((card) => _normalized(card.description) == _normalized(section.description));

    if (hasOverview) {
      cards.insert(
        0,
        BlueprintCardContent(
          title: section.subtitle?.trim().isNotEmpty == true ? section.subtitle! : 'Overview',
          description: section.description,
        ),
      );
    }

    return cards;
  }

  bool _isDuplicateCardTitle(BlueprintCardContent card, BlueprintSection section) {
    return _normalized(card.title).isNotEmpty &&
        _normalized(card.title) == _normalized(section.title);
  }

  bool _isDuplicateCardDescription(
    BlueprintCardContent card,
    BlueprintSection section,
  ) {
    return _normalized(card.description).isNotEmpty &&
        _normalized(card.description) == _normalized(section.description);
  }

  String _normalized(String text) => text.trim().toLowerCase();

  Widget _buildCardGrid(List<BlueprintCardContent> cards, BlueprintSection section) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final columns = maxW >= 920 ? 3 : (maxW >= 560 ? 2 : 1);
        final gap = 12.0;
        final cardWidth = (maxW - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: _buildCard(card, section.sectionType, section),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildCard(
    BlueprintCardContent card,
    String sectionType,
    BlueprintSection section,
  ) {
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (card.title.isNotEmpty && !_isDuplicateCardTitle(card, section))
            Text(
              card.title,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          if (card.description.isNotEmpty && !_isDuplicateCardDescription(card, section)) ...[
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
            ...card.items.map((item) => _buildListItem(item)),
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
    Color severityColor() {
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
        color: severityColor().withOpacity(0.1),
        border: Border(left: BorderSide(color: severityColor(), width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 16, color: severityColor()),
              const SizedBox(width: 8),
              Text(
                warning.title,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: severityColor(),
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
