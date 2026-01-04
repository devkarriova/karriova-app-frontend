import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/profile_model.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import 'common/custom_text_field.dart';

/// Form for managing certifications
class CertificationsEditForm extends StatelessWidget {
  final ProfileModel profile;

  const CertificationsEditForm({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with add button
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add your professional certifications',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showAddCertificationDialog(context),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      tooltip: 'Add Certification',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Certifications list
          if (profile.certifications.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_membership_outlined, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    'No certifications added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddCertificationDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first certification'),
                  ),
                ],
              ),
            )
          else
            ...profile.certifications.asMap().entries.map((entry) {
              final index = entry.key;
              final cert = entry.value;
              return _CertificationCard(
                certification: cert,
                onEdit: () => _showEditCertificationDialog(context, index, cert),
                onDelete: () => _confirmDelete(context, index, cert.name),
              );
            }),
        ],
      ),
    );
  }

  void _showAddCertificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _CertificationFormDialog(
        onSave: (name, issuer, issueDate, expiryDate, credentialUrl) {
          context.read<ProfileBloc>().add(ProfileCertificationAdded(
            name: name,
            issuer: issuer,
            issueDate: issueDate,
            expiryDate: expiryDate,
            credentialUrl: credentialUrl,
          ));
        },
      ),
    );
  }

  void _showEditCertificationDialog(BuildContext context, int index, Certification cert) {
    showDialog(
      context: context,
      builder: (ctx) => _CertificationFormDialog(
        certification: cert,
        onSave: (name, issuer, issueDate, expiryDate, credentialUrl) {
          context.read<ProfileBloc>().add(ProfileCertificationUpdated(
            index: index,
            name: name,
            issuer: issuer,
            issueDate: issueDate,
            expiryDate: expiryDate,
            credentialUrl: credentialUrl,
          ));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Certification'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ProfileCertificationDeleted(index: index));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CertificationCard extends StatelessWidget {
  final Certification certification;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CertificationCard({
    required this.certification,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');
    final issuedDate = dateFormat.format(certification.issueDate);
    final expiryInfo = certification.expiryDate != null
        ? ' • Expires ${dateFormat.format(certification.expiryDate!)}'
        : ' • No Expiry';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.card_membership_outlined, color: Colors.amber),
        ),
        title: Text(
          certification.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(certification.issuer),
            Text(
              'Issued $issuedDate$expiryInfo',
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _CertificationFormDialog extends StatefulWidget {
  final Certification? certification;
  final void Function(String name, String issuer, DateTime issueDate, DateTime? expiryDate, String credentialUrl) onSave;

  const _CertificationFormDialog({this.certification, required this.onSave});

  @override
  State<_CertificationFormDialog> createState() => _CertificationFormDialogState();
}

class _CertificationFormDialogState extends State<_CertificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _issuerController;
  late TextEditingController _credentialUrlController;
  late DateTime _issueDate;
  DateTime? _expiryDate;
  bool _hasExpiry = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.certification?.name ?? '');
    _issuerController = TextEditingController(text: widget.certification?.issuer ?? '');
    _credentialUrlController = TextEditingController(text: widget.certification?.credentialUrl ?? '');
    _issueDate = widget.certification?.issueDate ?? DateTime.now();
    _expiryDate = widget.certification?.expiryDate;
    _hasExpiry = _expiryDate != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final initialDate = isIssueDate ? _issueDate : (_expiryDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM yyyy');
    return AlertDialog(
      title: Text(widget.certification == null ? 'Add Certification' : 'Edit Certification'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Certification Name',
                  hint: 'e.g., AWS Solutions Architect',
                  controller: _nameController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Issuing Organization',
                  hint: 'e.g., Amazon Web Services',
                  controller: _issuerController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Issue Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => _selectDate(context, true),
                            child: Text(dateFormat.format(_issueDate)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_hasExpiry)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expiry Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _selectDate(context, false),
                              child: Text(_expiryDate != null ? dateFormat.format(_expiryDate!) : 'Select'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('This certification expires'),
                  value: _hasExpiry,
                  onChanged: (v) => setState(() {
                    _hasExpiry = v ?? false;
                    if (!_hasExpiry) _expiryDate = null;
                  }),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Credential URL (Optional)',
                  hint: 'https://credential.example.com/...',
                  controller: _credentialUrlController,
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.onSave(
                _nameController.text.trim(),
                _issuerController.text.trim(),
                _issueDate,
                _hasExpiry ? _expiryDate : null,
                _credentialUrlController.text.trim(),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
