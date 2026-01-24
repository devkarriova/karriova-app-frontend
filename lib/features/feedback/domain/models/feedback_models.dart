import 'package:equatable/equatable.dart';

/// Enum for ticket categories
enum TicketCategory {
  bug,
  featureRequest,
  uiUx,
  performance,
  other;

  String get displayName {
    switch (this) {
      case TicketCategory.bug:
        return 'Bug Report';
      case TicketCategory.featureRequest:
        return 'Feature Request';
      case TicketCategory.uiUx:
        return 'UI/UX Issue';
      case TicketCategory.performance:
        return 'Performance';
      case TicketCategory.other:
        return 'Other';
    }
  }

  String toJson() {
    switch (this) {
      case TicketCategory.bug:
        return 'bug';
      case TicketCategory.featureRequest:
        return 'feature_request';
      case TicketCategory.uiUx:
        return 'ui_ux';
      case TicketCategory.performance:
        return 'performance';
      case TicketCategory.other:
        return 'other';
    }
  }

  static TicketCategory fromJson(String json) {
    switch (json) {
      case 'bug':
        return TicketCategory.bug;
      case 'feature_request':
        return TicketCategory.featureRequest;
      case 'ui_ux':
        return TicketCategory.uiUx;
      case 'performance':
        return TicketCategory.performance;
      default:
        return TicketCategory.other;
    }
  }
}

/// Enum for ticket status
enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  String toJson() {
    switch (this) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }

  static TicketStatus fromJson(String json) {
    switch (json) {
      case 'open':
        return TicketStatus.open;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }
}

/// Enum for ticket priority
enum TicketPriority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.critical:
        return 'Critical';
    }
  }

  String toJson() {
    switch (this) {
      case TicketPriority.low:
        return 'low';
      case TicketPriority.medium:
        return 'medium';
      case TicketPriority.high:
        return 'high';
      case TicketPriority.critical:
        return 'critical';
    }
  }

  static TicketPriority fromJson(String json) {
    switch (json) {
      case 'low':
        return TicketPriority.low;
      case 'medium':
        return TicketPriority.medium;
      case 'high':
        return TicketPriority.high;
      case 'critical':
        return TicketPriority.critical;
      default:
        return TicketPriority.medium;
    }
  }
}

/// Model for a support ticket
class SupportTicket extends Equatable {
  final String id;
  final String userId;
  final TicketCategory category;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final String? appVersion;
  final String? deviceInfo;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketResponse> responses;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    this.appVersion,
    this.deviceInfo,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.responses = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: TicketCategory.fromJson(json['category'] as String),
      subject: json['subject'] as String,
      description: json['description'] as String,
      status: TicketStatus.fromJson(json['status'] as String),
      priority: TicketPriority.fromJson(json['priority'] as String),
      appVersion: json['app_version'] as String?,
      deviceInfo: json['device_info'] as String?,
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      responses: json['responses'] != null
          ? (json['responses'] as List)
              .map((r) => TicketResponse.fromJson(r as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category.toJson(),
      'subject': subject,
      'description': description,
      'status': status.toJson(),
      'priority': priority.toJson(),
      'app_version': appVersion,
      'device_info': deviceInfo,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'responses': responses.map((r) => r.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        subject,
        description,
        status,
        priority,
        appVersion,
        deviceInfo,
        assignedTo,
        createdAt,
        updatedAt,
        responses,
      ];
}

/// Model for a ticket response/comment
class TicketResponse extends Equatable {
  final String id;
  final String ticketId;
  final String userId;
  final String message;
  final bool isAdminResponse;
  final DateTime createdAt;

  const TicketResponse({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    required this.isAdminResponse,
    required this.createdAt,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      userId: json['user_id'] as String,
      message: json['message'] as String,
      isAdminResponse: json['is_admin_response'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'user_id': userId,
      'message': message,
      'is_admin_response': isAdminResponse,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        ticketId,
        userId,
        message,
        isAdminResponse,
        createdAt,
      ];
}

/// DTO for creating a ticket
class CreateTicketRequest {
  final TicketCategory category;
  final String subject;
  final String description;
  final String? appVersion;
  final String? deviceInfo;

  CreateTicketRequest({
    required this.category,
    required this.subject,
    required this.description,
    this.appVersion,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(),
      'subject': subject,
      'description': description,
      if (appVersion != null) 'app_version': appVersion,
      if (deviceInfo != null) 'device_info': deviceInfo,
    };
  }
}

/// Response for ticket list
class TicketListResponse {
  final List<SupportTicket> tickets;
  final int totalCount;
  final int page;
  final int pageSize;

  TicketListResponse({
    required this.tickets,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory TicketListResponse.fromJson(Map<String, dynamic> json) {
    return TicketListResponse(
      tickets: (json['tickets'] as List)
          .map((t) => SupportTicket.fromJson(t as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
}

/// Ticket statistics for admin dashboard
class TicketStats {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  TicketStats({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  factory TicketStats.fromJson(Map<String, dynamic> json) {
    return TicketStats(
      total: json['total'] as int? ?? 0,
      open: json['open'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      resolved: json['resolved'] as int? ?? 0,
      closed: json['closed'] as int? ?? 0,
    );
  }
}
