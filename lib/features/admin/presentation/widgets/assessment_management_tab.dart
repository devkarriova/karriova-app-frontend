import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection.dart';
import '../../../assessment/data/datasources/assessment_remote_datasource.dart';
import '../../../assessment/domain/models/assessment_models.dart';

/// Admin tab for KIT Assessment Management
/// Sections are read-only, only questions can be managed
class AssessmentManagementTab extends StatefulWidget {
  const AssessmentManagementTab({super.key});

  @override
  State<AssessmentManagementTab> createState() => _AssessmentManagementTabState();
}

class _AssessmentManagementTabState extends State<AssessmentManagementTab> {
  // Navigation state
  SectionModel? _selectedSection;

  // Data
  List<SectionModel> _sections = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
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
      _selectedSection = null;
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
        _buildContent(),
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
              onPressed: _loadSections,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
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
            child: Text(
              _selectedSection == null ? 'Assessment Sections' : _selectedSection!.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedSection != null) {
      return _SectionDetailView(
        section: _selectedSection!,
        onRefresh: _loadSections,
      );
    }

    return _SectionsListView(
      sections: _sections,
      onSectionTap: (section) => setState(() => _selectedSection = section),
      onRefresh: _loadSections,
    );
  }
}

/// Sections list view (read-only)
class _SectionsListView extends StatelessWidget {
  final List<SectionModel> sections;
  final Function(SectionModel) onSectionTap;
  final VoidCallback onRefresh;

  const _SectionsListView({
    required this.sections,
    required this.onSectionTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.folder_outlined, size: 56, color: AppColors.textTertiary),
              SizedBox(height: 16),
              Text(
                'No sections found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Assessment sections will appear here',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          // Handle both dimensions (old) and parameters (new KIT)
          final dimensionCount = section.parameters != null
              ? section.parameters!.length
              : section.dimensions.length;
          final questionCount = section.parameters != null
              ? section.parameters!.fold<int>(0, (sum, p) => sum + p.questions.length)
              : section.dimensions.fold<int>(0, (sum, d) => sum + d.questions.length);

          return Card(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              side: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            child: InkWell(
              onTap: () => onSectionTap(section),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.psychology, color: Colors.white, size: 24),
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
                          const SizedBox(height: 4),
                          if (section.description.isNotEmpty)
                            Text(
                              section.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            '$dimensionCount parameters • $questionCount questions',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
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
        },
      ),
    );
  }
}

/// Section detail view with parameters and question management
class _SectionDetailView extends StatelessWidget {
  final SectionModel section;
  final VoidCallback onRefresh;

  const _SectionDetailView({
    required this.section,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Info Card
          Card(
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Section Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (section.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      section.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Parameters Section
          const Text(
            'Parameters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildParametersList(),
          const SizedBox(height: 24),

          // Question Management Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadTemplate(context),
                  icon: const Icon(Icons.download, size: 20),
                  label: const Text('Download Template'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _uploadQuestions(context),
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: const Text('Bulk Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Questions List
          const Text(
            'Questions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${_getTotalQuestions()} questions',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuestionsList(),
        ],
      ),
    );
  }

  int _getTotalQuestions() {
    if (section.parameters != null && section.parameters!.isNotEmpty) {
      return section.parameters!.fold<int>(0, (sum, p) => sum + p.questions.length);
    }
    return section.dimensions.fold<int>(0, (sum, d) => sum + d.questions.length);
  }

  Widget _buildParametersList() {
    // Handle both parameters (new KIT) and dimensions (old)
    final hasParameters = section.parameters != null && section.parameters!.isNotEmpty;
    final hasDimensions = section.dimensions.isNotEmpty;

    if (!hasParameters && !hasDimensions) {
      return const Text(
        'No parameters defined for this section',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      );
    }

    if (hasParameters) {
      // New KIT structure: display parameters
      return Column(
        children: section.parameters!.map((parameter) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.border.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              parameter.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                parameter.code,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (parameter.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            parameter.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        if (parameter.poleALabel != null && parameter.poleBLabel != null)
                          Row(
                            children: [
                              Text(
                                parameter.poleALabel!,
                                style: const TextStyle(fontSize: 11, color: AppColors.primary),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.arrow_forward, size: 12, color: AppColors.textTertiary),
                              ),
                              Text(
                                parameter.poleBLabel!,
                                style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${parameter.questions.length} questions',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    // Old structure: display dimensions
    return Column(
      children: section.dimensions.map((dimension) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dimension.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (dimension.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          dimension.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            dimension.poleALabel,
                            style: const TextStyle(fontSize: 11, color: AppColors.primary),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward, size: 12, color: AppColors.textTertiary),
                          ),
                          Text(
                            dimension.poleBLabel,
                            style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${dimension.questions.length} questions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionsList() {
    final allQuestions = <QuestionModel>[];

    // Collect questions from parameters or dimensions
    if (section.parameters != null && section.parameters!.isNotEmpty) {
      for (final parameter in section.parameters!) {
        allQuestions.addAll(parameter.questions);
      }
    } else {
      for (final dimension in section.dimensions) {
        allQuestions.addAll(dimension.questions);
      }
    }

    if (allQuestions.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No questions yet. Upload questions using bulk upload.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final questionWidgets = <Widget>[];

    questionWidgets.addAll(allQuestions.take(5).map((question) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: question.options.map((option) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${option.text} (${option.score})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }));

    if (allQuestions.length > 5) {
      questionWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '... and ${allQuestions.length - 5} more questions',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Column(children: questionWidgets);
  }

  Future<void> _downloadTemplate(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Preparing template download...'),
        backgroundColor: AppColors.primary,
      ),
    );

    try {
      final datasource = getIt<AssessmentRemoteDataSource>();
      final template = await datasource.downloadQuestionTemplate(section.id);

      String? savedPath;
      if (kIsWeb) {
        _downloadTemplateOnWeb(
          Uint8List.fromList(template.bytes),
          template.fileName,
        );
        savedPath = 'browser-download';
      } else {
        savedPath = _resolveTemplateOutputPath(template.fileName);
        await File(savedPath).writeAsBytes(template.bytes, flush: true);
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Template saved: $savedPath'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to download template: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _resolveTemplateOutputPath(String requestedFileName) {
    final sanitizedName = requestedFileName.trim().isEmpty
        ? 'KIT_Question_Template.xlsx'
        : requestedFileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    final normalizedFileName = sanitizedName.toLowerCase().endsWith('.xlsx')
        ? sanitizedName
        : '$sanitizedName.xlsx';

    final outputDirectory = _resolvePreferredDownloadDirectory();
    return '${outputDirectory.path}${Platform.pathSeparator}$normalizedFileName';
  }

  Directory _resolvePreferredDownloadDirectory() {
    final candidates = <String>[];

    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null && userProfile.isNotEmpty) {
        candidates.add('$userProfile${Platform.pathSeparator}Downloads');
        candidates.add('$userProfile${Platform.pathSeparator}Documents');
      }
    } else {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        candidates.add('$home${Platform.pathSeparator}Downloads');
      }
    }

    for (final path in candidates) {
      final dir = Directory(path);
      if (dir.existsSync()) {
        return dir;
      }
    }

    return Directory.current;
  }

  void _downloadTemplateOnWeb(Uint8List bytes, String fileName) {
    final safeFileName = fileName.trim().isEmpty ? 'KIT_Question_Template.xlsx' : fileName;
    final blob = html.Blob(
      [bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', safeFileName)
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  void _uploadQuestions(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BulkUploadDialog(
        section: section,
        onUploadComplete: onRefresh,
      ),
    );
  }
}


class _BulkUploadDialog extends StatefulWidget {
  final SectionModel section;
  final VoidCallback onUploadComplete;

  const _BulkUploadDialog({
    required this.section,
    required this.onUploadComplete,
  });

  @override
  State<_BulkUploadDialog> createState() => _BulkUploadDialogState();
}

class _BulkUploadDialogState extends State<_BulkUploadDialog> {
  PlatformFile? _selectedFile;
  BulkValidationResponseModel? _validationResult;
  bool _isValidating = false;
  bool _isUploading = false;

  AssessmentRemoteDataSource get _datasource => getIt<AssessmentRemoteDataSource>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Upload Questions'),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Section: ${widget.section.name}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isValidating || _isUploading ? null : _pickExcelFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile?.name ?? 'Choose Excel File (.xlsx)'),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${_selectedFile!.name} (${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectedFile == null || _isValidating || _isUploading
                          ? null
                          : _validateFile,
                      icon: _isValidating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.fact_check),
                      label: const Text('Validate'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _canUpload ? _uploadFile : null,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: const Text('Upload'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildValidationPreview(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isValidating || _isUploading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  bool get _canUpload {
    return _selectedFile != null &&
        _validationResult != null &&
        _validationResult!.valid &&
        !_isUploading &&
        !_isValidating;
  }

  Future<void> _pickExcelFile() async {
    if (kIsWeb) {
      await _pickExcelFileWeb();
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _selectedFile = result.files.first;
      _validationResult = null;
    });
  }

  Future<void> _pickExcelFileWeb() async {
    final input = html.FileUploadInputElement()
      ..accept = '.xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    input.click();

    await input.onChange.first;
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      return;
    }

    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onError.listen((_) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Failed to read file in browser'));
      }
    });

    reader.onLoadEnd.listen((_) {
      if (completer.isCompleted) {
        return;
      }
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(Uint8List.view(result));
      } else {
        completer.completeError(Exception('Unexpected browser file payload'));
      }
    });

    reader.readAsArrayBuffer(file);
    final bytes = await completer.future;

    setState(() {
      _selectedFile = PlatformFile(
        name: file.name,
        size: bytes.length,
        bytes: bytes,
      );
      _validationResult = null;
    });
  }

  Future<void> _validateFile() async {
    final file = _selectedFile;
    if (file == null || file.bytes == null) {
      _showError('Please select a valid file');
      return;
    }

    setState(() => _isValidating = true);
    try {
      final validation = await _datasource.validateBulkQuestions(
        widget.section.id,
        fileBytes: file.bytes!,
        fileName: file.name,
      );
      setState(() {
        _validationResult = validation;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.valid
              ? 'Validation passed. Ready to upload.'
              : 'Validation failed with ${validation.errors.length} error(s).'),
          backgroundColor: validation.valid ? AppColors.success : AppColors.warning,
        ),
      );
    } catch (e) {
      _showError('Validation failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  Future<void> _uploadFile() async {
    final file = _selectedFile;
    if (file == null || file.bytes == null) {
      _showError('Please choose an Excel file first');
      return;
    }

    setState(() => _isUploading = true);
    try {
      final result = await _datasource.bulkUploadQuestions(
        widget.section.id,
        fileBytes: file.bytes!,
        fileName: file.name,
      );

      if (!mounted) return;
      if (!result.success) {
        _showError(result.errorMessage ?? 'Upload failed');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uploaded ${result.questionIds.length} questions successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onUploadComplete();
      Navigator.of(context).pop();
    } catch (e) {
      _showError('Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildValidationPreview() {
    final result = _validationResult;
    if (result == null) {
      return const Text(
        'Upload process: Choose file -> Validate -> Upload',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      );
    }

    final summary = result.summary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.valid ? 'Validation Passed' : 'Validation Failed',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: result.valid ? AppColors.success : AppColors.error,
            ),
          ),
          if (summary != null) ...[
            const SizedBox(height: 6),
            Text('Total questions: ${summary.totalQuestions}'),
            Text('Warnings: ${result.warnings.length}'),
            Text('Errors: ${result.errors.length}'),
          ],
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('Top errors:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...result.errors.take(5).map(
                  (e) => Text(
                    'Row ${e.rowNumber} - ${e.field}: ${e.message}',
                    style: const TextStyle(fontSize: 12, color: AppColors.error),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
