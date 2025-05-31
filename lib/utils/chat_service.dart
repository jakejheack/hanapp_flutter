import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hanapp/utils/api_config.dart';
import 'package:hanapp/models/message.dart'; // NEW
import 'package:hanapp/models/conversation.dart'; // NEW

class ChatService {
  Future<Map<String, dynamic>> sendMessage({
    required int senderId,
    required int receiverId,
    int? listingId,
    required String messageText,
  }) async {
    try {
      // Removed token retrieval
      final response = await http.post(
        Uri.parse(ApiConfig.sendMessageEndpoint),
        headers: {
          'Content-Type': 'application/json',
          // Removed 'Authorization' header
        },
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'listing_id': listingId,
          'message_text': messageText,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMessages({
    required int user1Id,
    required int user2Id,
    int? listingId,
  }) async {
    try {
      // Removed token retrieval
      Map<String, String> queryParams = {
        'user1_id': user1Id.toString(),
        'user2_id': user2Id.toString(),
      };
      if (listingId != null) {
        queryParams['listing_id'] = listingId.toString();
      }

      final uri = Uri.parse(ApiConfig.getMessagesEndpoint).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          // Removed 'Authorization' header
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        List<Message> messages = (responseBody['messages'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
        return {'success': true, 'messages': messages};
      }
      return responseBody;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // NEW: Get list of conversations for a user
  // Future<Map<String, dynamic>> getConversations(int userId) async {
  //   try {
  //     // Removed token retrieval
  //     final uri = Uri.parse(ApiConfig.getConversationsEndpoint).replace(queryParameters: {'user_id': userId.toString()});
  //     final response = await http.get(
  //       uri,
  //       headers: {
  //         // Removed 'Authorization' header
  //       },
  //     );
  //
  //     final Map<String, dynamic> responseBody = jsonDecode(response.body);
  //     if (responseBody['success']) {
  //       List<Conversation> conversations = (responseBody['conversations'] as List)
  //           .map((json) => Conversation.fromJson(json))
  //           .toList();
  //       return {'success': true, 'conversations': conversations};
  //     }
  //     return responseBody;
  //   } catch (e) {
  //     return {'success': false, 'message': 'Network error: $e'};
  //   }
  // }
}