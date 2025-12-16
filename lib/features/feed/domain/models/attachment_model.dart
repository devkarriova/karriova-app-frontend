class AttachmentModel {
  final String id;
  final String postId;
  final String type; // 'image', 'video', 'document'
  final String fileName;
  final String filePath;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final int? width;
  final int? height;
  final int? duration;
  final String? thumbnailUrl;
  final String storageType;
  final DateTime createdAt;

  AttachmentModel({
    required this.id,
    required this.postId,
    required this.type,
    required this.fileName,
    required this.filePath,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    this.width,
    this.height,
    this.duration,
    this.thumbnailUrl,
    required this.storageType,
    required this.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      type: json['type'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      fileUrl: json['file_url'] as String,
      fileSize: json['file_size'] as int,
      mimeType: json['mime_type'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      storageType: json['storage_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'type': type,
      'file_name': fileName,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_size': fileSize,
      'mime_type': mimeType,
      'width': width,
      'height': height,
      'duration': duration,
      'thumbnail_url': thumbnailUrl,
      'storage_type': storageType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isDocument => type == 'document';
}
