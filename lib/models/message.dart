class Message {
  final int id;
  final int senderId;
  final int receiverId; // This is inferred from the conversation participants
  final int? listingId; // Optional, if message is tied to a specific listing
  final String messageText;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.listingId,
    required this.messageText,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: int.parse(json['id'].toString()),
      senderId: int.parse(json['sender_id'].toString()),
      // In get_messages.php, receiver_id is now explicitly returned
      receiverId: int.parse(json['receiver_id'].toString()),
      listingId: json['listing_id'] != null ? int.parse(json['listing_id'].toString()) : null,
      messageText: json['message_text'],
      sentAt: DateTime.parse(json['sent_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'listing_id': listingId,
      'message_text': messageText,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}