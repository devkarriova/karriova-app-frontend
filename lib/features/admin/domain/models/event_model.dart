import 'package:equatable/equatable.dart';

/// Event model for admin event management
class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? shortDescription;
  final String? categoryId;
  final String? categoryName;
  final String eventType; // in_person, virtual, hybrid
  final String? location;
  final String? address;
  final String? city;
  final String? country;
  final bool isVirtual;
  final String? virtualPlatform;
  final String? virtualLink;
  final DateTime startTime;
  final DateTime endTime;
  final String timezone;
  final String? coverImage;
  final String? thumbnailImage;
  final int? maxAttendees;
  final DateTime? registrationDeadline;
  final bool isRegistrationRequired;
  final double registrationFee;
  final String currency;
  final String status; // draft, published, cancelled, completed
  final bool isFeatured;
  final bool isPublic;
  final String? organizerName;
  final String? organizerEmail;
  final List<String> tags;
  final int attendeeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.shortDescription,
    this.categoryId,
    this.categoryName,
    this.eventType = 'in_person',
    this.location,
    this.address,
    this.city,
    this.country,
    this.isVirtual = false,
    this.virtualPlatform,
    this.virtualLink,
    required this.startTime,
    required this.endTime,
    this.timezone = 'UTC',
    this.coverImage,
    this.thumbnailImage,
    this.maxAttendees,
    this.registrationDeadline,
    this.isRegistrationRequired = true,
    this.registrationFee = 0,
    this.currency = 'USD',
    this.status = 'draft',
    this.isFeatured = false,
    this.isPublic = true,
    this.organizerName,
    this.organizerEmail,
    this.tags = const [],
    this.attendeeCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      shortDescription: json['short_description'] as String?,
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      eventType: json['event_type'] as String? ?? 'in_person',
      location: json['location'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      isVirtual: json['is_virtual'] as bool? ?? false,
      virtualPlatform: json['virtual_platform'] as String?,
      virtualLink: json['virtual_link'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      timezone: json['timezone'] as String? ?? 'UTC',
      coverImage: json['cover_image'] as String?,
      thumbnailImage: json['thumbnail_image'] as String?,
      maxAttendees: json['max_attendees'] as int?,
      registrationDeadline: json['registration_deadline'] != null
          ? DateTime.parse(json['registration_deadline'] as String)
          : null,
      isRegistrationRequired: json['is_registration_required'] as bool? ?? true,
      registrationFee: (json['registration_fee'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'draft',
      isFeatured: json['is_featured'] as bool? ?? false,
      isPublic: json['is_public'] as bool? ?? true,
      organizerName: json['organizer_name'] as String?,
      organizerEmail: json['organizer_email'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      attendeeCount: json['attendee_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'short_description': shortDescription,
      'category_id': categoryId,
      'event_type': eventType,
      'location': location,
      'address': address,
      'city': city,
      'country': country,
      'is_virtual': isVirtual,
      'virtual_platform': virtualPlatform,
      'virtual_link': virtualLink,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'timezone': timezone,
      'cover_image': coverImage,
      'thumbnail_image': thumbnailImage,
      'max_attendees': maxAttendees,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'is_registration_required': isRegistrationRequired,
      'registration_fee': registrationFee,
      'currency': currency,
      'status': status,
      'is_featured': isFeatured,
      'is_public': isPublic,
      'organizer_name': organizerName,
      'organizer_email': organizerEmail,
      'tags': tags,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? shortDescription,
    String? categoryId,
    String? categoryName,
    String? eventType,
    String? location,
    String? address,
    String? city,
    String? country,
    bool? isVirtual,
    String? virtualPlatform,
    String? virtualLink,
    DateTime? startTime,
    DateTime? endTime,
    String? timezone,
    String? coverImage,
    String? thumbnailImage,
    int? maxAttendees,
    DateTime? registrationDeadline,
    bool? isRegistrationRequired,
    double? registrationFee,
    String? currency,
    String? status,
    bool? isFeatured,
    bool? isPublic,
    String? organizerName,
    String? organizerEmail,
    List<String>? tags,
    int? attendeeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      eventType: eventType ?? this.eventType,
      location: location ?? this.location,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      isVirtual: isVirtual ?? this.isVirtual,
      virtualPlatform: virtualPlatform ?? this.virtualPlatform,
      virtualLink: virtualLink ?? this.virtualLink,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timezone: timezone ?? this.timezone,
      coverImage: coverImage ?? this.coverImage,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      isRegistrationRequired: isRegistrationRequired ?? this.isRegistrationRequired,
      registrationFee: registrationFee ?? this.registrationFee,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublic: isPublic ?? this.isPublic,
      organizerName: organizerName ?? this.organizerName,
      organizerEmail: organizerEmail ?? this.organizerEmail,
      tags: tags ?? this.tags,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  /// Check if event is upcoming
  bool get isUpcoming => startTime.isAfter(DateTime.now());

  /// Check if event is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if event has ended
  bool get hasEnded => endTime.isBefore(DateTime.now());

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'published':
        return 'Published';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  /// Get event type display text
  String get eventTypeDisplay {
    switch (eventType) {
      case 'in_person':
        return 'In Person';
      case 'virtual':
        return 'Virtual';
      case 'hybrid':
        return 'Hybrid';
      default:
        return eventType;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        shortDescription,
        categoryId,
        categoryName,
        eventType,
        location,
        address,
        city,
        country,
        isVirtual,
        virtualPlatform,
        virtualLink,
        startTime,
        endTime,
        timezone,
        coverImage,
        thumbnailImage,
        maxAttendees,
        registrationDeadline,
        isRegistrationRequired,
        registrationFee,
        currency,
        status,
        isFeatured,
        isPublic,
        organizerName,
        organizerEmail,
        tags,
        attendeeCount,
        createdAt,
        updatedAt,
        publishedAt,
      ];
}

/// Event category model
class EventCategoryModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final bool isActive;
  final int sortOrder;

  const EventCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) {
    return EventCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, description, icon, color, isActive, sortOrder];
}

/// Event list response with pagination
class EventListResponse {
  final List<EventModel> events;
  final int total;
  final int limit;
  final int offset;
  final int totalPages;

  EventListResponse({
    required this.events,
    required this.total,
    required this.limit,
    required this.offset,
    required this.totalPages,
  });

  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    return EventListResponse(
      events: (json['events'] as List<dynamic>)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      totalPages: json['total_pages'] as int,
    );
  }
}
