class LegalDocument {
  final String slug;
  final String title;
  final String version;
  final String effectiveDate;
  final String lastUpdated;
  final bool requiresAcceptance;
  final bool requiredWhenMinor;
  final List<String> requiredRoles;
  final String documentHash;
  final String? downloadUrl;
  final List<String> body;
  final List<String> contacts;

  const LegalDocument({
    required this.slug,
    required this.title,
    required this.version,
    required this.effectiveDate,
    required this.lastUpdated,
    required this.requiresAcceptance,
    required this.requiredWhenMinor,
    required this.requiredRoles,
    required this.documentHash,
    required this.body,
    required this.contacts,
    this.downloadUrl,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      version: json['version'] as String? ?? '',
      effectiveDate: json['effective_date'] as String? ?? '',
      lastUpdated: json['last_updated'] as String? ?? '',
      requiresAcceptance: json['requires_acceptance'] as bool? ?? false,
      requiredWhenMinor: json['required_when_minor'] as bool? ?? false,
      requiredRoles: ((json['required_roles'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      documentHash: json['document_hash'] as String? ?? '',
      downloadUrl: json['download_url'] as String?,
      body: ((json['body'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      contacts: ((json['contacts'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  bool isRequiredFor({required String role, required bool isMinor}) {
    if (!requiresAcceptance) return false;
    if (requiredWhenMinor && !isMinor) return false;
    return requiredRoles.contains('all') || requiredRoles.contains(role);
  }

  Map<String, String> acceptancePayload() => {
        'slug': slug,
        'version': version,
        'document_hash': documentHash,
      };
}
