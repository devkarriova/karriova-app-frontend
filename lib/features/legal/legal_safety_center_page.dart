import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import 'legal_document_model.dart';
import 'legal_service.dart';

class LegalSafetyCenterPage extends StatefulWidget {
  const LegalSafetyCenterPage({super.key});

  @override
  State<LegalSafetyCenterPage> createState() => _LegalSafetyCenterPageState();
}

class _LegalSafetyCenterPageState extends State<LegalSafetyCenterPage> {
  late final LegalService _service;
  late Future<List<LegalDocument>> _future;

  @override
  void initState() {
    super.initState();
    _service = LegalService(GetIt.instance<ApiClient>());
    _future = _service.getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal & Safety')),
      body: FutureBuilder<List<LegalDocument>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _future = _service.getDocuments();
                }),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }
          final docs = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _ComplianceNotice(),
              const SizedBox(height: 16),
              for (final doc in docs)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      doc.requiresAcceptance
                          ? Icons.verified_user_outlined
                          : Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(doc.title),
                    subtitle: Text(
                        'Version ${doc.version} | Updated ${doc.lastUpdated}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/legal/${doc.slug}'),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.push('/settings/help'),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Raise Grievance or Safety Report'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ComplianceNotice extends StatelessWidget {
  const _ComplianceNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Karriova publishes these policies so students, parents, mentors, and users can understand data use, AI limitations, safety rules, grievance channels, and refund rights.',
        style: TextStyle(height: 1.45),
      ),
    );
  }
}
