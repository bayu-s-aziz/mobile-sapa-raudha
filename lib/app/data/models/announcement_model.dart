// lib/app/data/models/announcement_model.dart
import 'package:intl/intl.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String author;
  final String? attachmentName;
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
    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      author: json['author'] ?? json['created_by'] ?? '',
      attachmentName: json['attachment_name'] ?? json['attachment'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      isPinned: json['is_pinned'] == 1 || json['is_pinned'] == true,
      category: json['category'],
      imageUrl: json['image_url'],
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
      isRead: isRead ?? this.isRead,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
