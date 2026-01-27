// lib/app/data/models/announcement_model.dart
import 'package:intl/intl.dart';
import 'package:sapa_raudha/app/utils/url_utils.dart';

class Announcement {
  /// Return an absolute URL for the `imageUrl` when possible.
  String? get normalizedImageUrl => UrlUtils.normalizeUrl(imageUrl);
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String author;
  final String? attachmentName;
  final List<Map<String, dynamic>> attachments;
  final bool isRead;
  final bool isPinned;
  final String? category;
  final String? imageUrl;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.author,
    this.attachmentName,
    this.attachments = const [],
    this.isRead = false,
    this.isPinned = false,
    this.category,
    this.imageUrl,
  });

  String get formattedDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(timestamp);
  }

  // For compatibility with admin views
  DateTime get createdAt => timestamp;
  String get createdBy => author;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    // Normalize image_url (may be a relative path) using UrlUtils
    final rawImage = json['image_url'] as String?;
    final normalizedImage = UrlUtils.normalizeUrl(rawImage);

    // Normalize attachment URLs (file_url / url) when possible so views can
    // rely on absolute URLs.
    final attachments = json['attachments'] is List
        ? List<Map<String, dynamic>>.from(json['attachments'])
              .map((att) {
                final fileUrl = (att['file_url'] ?? att['url']) as String?;
                if (fileUrl != null && fileUrl.isNotEmpty) {
                  final normalized = UrlUtils.normalizeUrl(fileUrl);
                  if (normalized != null) {
                    att['file_url'] = normalized;
                    att['url'] = normalized;
                  }
                }
                return att;
              })
              .toList()
              .cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      author: json['author'] is Map<String, dynamic>
          ? json['author']['name'] ?? ''
          : json['author'] ?? json['created_by'] ?? '',
      attachmentName: json['attachment_name'] ?? json['attachment'],
      attachments: attachments,
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      isPinned: json['is_pinned'] == 1 || json['is_pinned'] == true,
      category: json['category'],
      imageUrl: normalizedImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'created_at': timestamp.toIso8601String(),
      'author': author,
      'created_by': author,
      'attachment_name': attachmentName,
      'attachments': attachments,
      'is_read': isRead ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'category': category,
      'image_url': imageUrl,
    };
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
    String? author,
    String? attachmentName,
    List<Map<String, dynamic>>? attachments,
    bool? isRead,
    bool? isPinned,
    String? category,
    String? imageUrl,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      author: author ?? this.author,
      attachmentName: attachmentName ?? this.attachmentName,
      attachments: attachments ?? this.attachments,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
