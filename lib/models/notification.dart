enum NotificationType { application, message, reply, job_confirmed, review_received, unknown, job_marked_done_by_doer, job_completed, }

class AppNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final int? relatedEntityId;
  final bool isRead;
  final DateTime timestamp;
  final String? senderName;
  final String? senderProfilePictureUrl;
  final int? senderId; // NEW: Add senderId here

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.relatedEntityId,
    this.isRead = false,
    required this.timestamp,
    this.senderName,
    this.senderProfilePictureUrl,
    this.senderId, // Initialize senderId
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    NotificationType parsedType;
    try {
      parsedType = NotificationType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.unknown,
      );
    } catch (e) {
      parsedType = NotificationType.unknown;
    }
    return AppNotification(
      id: int.parse(json['id'].toString()),
      type: NotificationType.values.firstWhere((e) => e.toString().split('.').last == json['type'], orElse: () => NotificationType.message /* Default or error type */),
      title: json['title'],
      message: json['message'],
      relatedEntityId: json['related_entity_id'] != null ? int.parse(json['related_entity_id'].toString()) : null,
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      timestamp: DateTime.parse(json['timestamp']),
      senderName: json['sender_name'],
      senderProfilePictureUrl: json['sender_profile_picture_url'] as String?,
      senderId: json['sender_id'] != null ? int.parse(json['sender_id'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'related_entity_id': relatedEntityId,
      'is_read': isRead,
      'timestamp': timestamp.toIso8601String(),
      'sender_name': senderName,
      'sender_profile_picture_url': senderProfilePictureUrl,
      'sender_id': senderId,
    };
  }
}