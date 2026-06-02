import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_router.dart';
import 'legal_document_model.dart';
import 'legal_service.dart';

class PolicyReviewPage extends StatefulWidget {
  const PolicyReviewPage({super.key});

  @override
  State<PolicyReviewPage> createState() => _PolicyReviewPageState();
}

class _PolicyReviewPageState extends State<PolicyReviewPage> {
  late final LegalService _service;
  late Future<List<LegalDocument>> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _service = LegalService(GetIt.instance<ApiClient>());
    _future = _service.getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Required Policies')),
      body: FutureBuilder<List<LegalDocument>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final requiredDocs =
              snapshot.data!.where((doc) => doc.requiresAcceptance).toList();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Please review and accept the current Legal & Safety policies before continuing.',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              for (final doc in requiredDocs)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: AppColors.primary),
                  title: Text(doc.title),
                  subtitle: Text('Version ${doc.version}'),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await _service.acceptDocuments(documents: requiredDocs);
                        if (!context.mounted) return;
                        context.go(AppRouter.feed);
                      },
                child: Text(_saving ? 'Saving...' : 'Accept and Continue'),
              ),
            ],
          );
        },
      ),
    );
  }
}
