import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import 'legal_document_model.dart';
import 'legal_service.dart';

class LegalDocumentPage extends StatefulWidget {
  final String slug;
  final String? initialTitle;

  const LegalDocumentPage({
    super.key,
    required this.slug,
    this.initialTitle,
  });

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  late final LegalService _service;
  late Future<LegalDocument> _future;

  @override
  void initState() {
    super.initState();
    _service = LegalService(GetIt.instance<ApiClient>());
    _future = _service.getDocument(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.initialTitle ?? 'Legal Document')),
      body: FutureBuilder<LegalDocument>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _future = _service.getDocument(widget.slug);
                }),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }
          final doc = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                doc.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version ${doc.version} | Effective ${doc.effectiveDate} | Last updated ${doc.lastUpdated}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _download(doc),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download PDF'),
              ),
              const SizedBox(height: 20),
              for (final paragraph in doc.body) _PolicyParagraph(paragraph),
              if (doc.contacts.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Contacts',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(doc.contacts.join('\n')),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _download(LegalDocument doc) async {
    final url = LegalService.absoluteDownloadUrl(doc.downloadUrl);
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _PolicyParagraph extends StatelessWidget {
  final String text;

  const _PolicyParagraph(this.text);

  @override
  Widget build(BuildContext context) {
    final isHeading = text.length < 120 &&
        (RegExp(r'^\d+\.').hasMatch(text) ||
            text.toUpperCase() == text ||
            text.endsWith('Policy') ||
            text.endsWith('Agreement'));
    return Padding(
      padding:
          EdgeInsets.only(bottom: isHeading ? 10 : 12, top: isHeading ? 8 : 0),
      child: Text(
        text,
        style: isHeading
            ? Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.primary)
            : Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
      ),
    );
  }
}
