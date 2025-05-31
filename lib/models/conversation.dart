import 'package:intl/intl.dart';

class Conversation {
  final int id;
  final int user1Id;
  final int user2Id;
  final String user1Name;
  final String? user1ProfilePictureUrl;
  final String user2Name;
  final String? user2ProfilePictureUrl;
  final int? listingId;
  final String? listingTitle;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int? applicationId;
  // Helper properties for the UI
  final int otherUserId;
  final String otherUserName;
  final String? otherUserProfilePictureUrl;

  Conversation( {
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    this.user1ProfilePictureUrl,
    required this.user2Name,
    this.user2ProfilePictureUrl,
    this.listingId,
    this.listingTitle,
    this.lastMessage,
    this.lastMessageTime,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePictureUrl,
    this.applicationId,

  });

  factory Conversation.fromJson(Map<String, dynamic> json, int currentUserId) {
    // Determine which user is the "other" participant in the conversation
    final int otherUserId = json['user1_id'] == currentUserId ? int.parse(json['user2_id'].toString()) : int.parse(json['user1_id'].toString());
    final String otherUserName = json['user1_id'] == currentUserId ? json['user2_name'] : json['user1_name'];
    final String? otherUserProfilePictureUrl = json['user1_id'] == currentUserId ? json['user2_profile_picture_url'] : json['user1_profile_picture_url'];

    return Conversation(
      id: json['id'] as int,
      user1Id: json['user1_id'] as int,
      user2Id: json['user2_id'] as int,
      user1Name: json['user1_name'],
      user1ProfilePictureUrl: json['user1_profile_picture_url'],
      user2Name: json['user2_name'],
      user2ProfilePictureUrl: json['user2_profile_picture_url'],
      listingId: json['listing_id'] as int?, // Use 'as int?'
      listingTitle: json['listing_title'] as String?, // Use 'as String?'
      lastMessage: json['last_message'] as String?, // Use 'as String?'
      lastMessageTime: json['last_message_time'] != null ? DateTime.parse(json['last_message_time']) : null,
      otherUserId: json['other_user_id'] as int,
      otherUserName: json['other_user_name'] as String,
      otherUserProfilePictureUrl: json['other_user_profile_picture_url'] as String?, // Use 'as String?'
      applicationId: json['application_id'] as int?, // Make sure it's parsed
    );
  }

  String get formattedLastMessageTime {
    if (lastMessageTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(lastMessageTime!); // e.g., 10:30 AM
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(lastMessageTime!); // e.g., Mon, Tue
    } else if (difference.inDays < 365) {
      return DateFormat.MMMd().format(lastMessageTime!); // e.g., Jan 15
    } else {
      return DateFormat.yMMMd().format(lastMessageTime!); // e.g., Jan 15, 2023
    }
  }
}