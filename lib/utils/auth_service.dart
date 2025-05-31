// hanapp_flutter/lib/utils/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hanapp/utils/api_config.dart';
import 'package:hanapp/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hanapp/models/review.dart'; // Import Review model

class AuthService {
  static const String _userKey = 'currentUser';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<Map<String, dynamic>> registerUser({
    required String full_name,
    required String first_name,
    required String last_name,
    String? birth_date,
    String? address_details,
    double? latitude,
    double? longitude,
    String? gender,
    String? contact_number,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': full_name,
          'first_name': first_name,
          'last_name': last_name,
          'birth_date': birth_date,
          'address_details': address_details,
          'latitude': latitude,
          'longitude': longitude,
          'gender': gender,
          'contact_number': contact_number,
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        final user = User.fromJson(responseBody['user']);
        await saveUser(user);
      }
      return responseBody;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyEmailEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Upload profile picture without token
  Future<Map<String, dynamic>> uploadProfilePicture(String userId, XFile imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.uploadProfilePictureEndpoint));
      request.fields['user_id'] = userId;

      // Use fromBytes for web compatibility
      request.files.add(http.MultipartFile.fromBytes(
        'profile_picture',
        await imageFile.readAsBytes(),
        filename: imageFile.name,
        contentType: MediaType('image', imageFile.mimeType?.split('/')[1] ?? 'jpeg'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateRole(String userId, String role) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updateRoleEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'role': role}),
      );
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      // If the backend indicates success, update the locally stored user data
      if (responseBody['success'] == true) {
        User? currentUser = await getUser(); // Get the current user from local storage
        if (currentUser != null) {
          User updatedUser = User(
            id: currentUser.id,
            fullName: currentUser.fullName,
            email: currentUser.email,
            role: role, // Update the role
            isVerified: currentUser.isVerified,
            profilePictureUrl: currentUser.profilePictureUrl,
            averageRating: currentUser.averageRating,
            reviewCount: currentUser.reviewCount,
            latitude: currentUser.latitude,
            longitude: currentUser.longitude,
          );
          await saveUser(updatedUser);
        }
      }
      return responseBody;
    } catch (e) {
      // Catch any network or parsing errors
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // New method to update user profile with location and contact number
  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String fullName,
    required String email,
    String? contactNumber,
    String? addressDetails,
    double? latitude,
    double? longitude,
    XFile? profilePictureFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.updateUserProfileEndpoint), // Assuming you have this endpoint
      );
      request.fields['user_id'] = userId.toString();
      request.fields['full_name'] = fullName;
      request.fields['email'] = email;
      if (contactNumber != null) request.fields['contact_number'] = contactNumber;
      if (addressDetails != null) request.fields['address_details'] = addressDetails;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      if (profilePictureFile != null) {
        request.files.add(await http.MultipartFile.fromPath('profile_picture', profilePictureFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true) {
        // Update the locally stored user data after successful update
        final updatedUser = User.fromJson(responseBody['user']);
        await saveUser(updatedUser);
      }
      return responseBody;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> blockUser({
    required int userId,
    required int blockedUserId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.blockUserEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'blocked_user_id': blockedUserId,
        }),
      );
      print('Block User API Response: ${response.body}'); // Debugging
      return jsonDecode(response.body);
    } catch (e) {
      print('Block User Network Error: $e'); // Debugging
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Method to get a single user's profile by ID
  Future<Map<String, dynamic>> getUserProfileById({required int userId}) async {
    try {
      final uri = Uri.parse(ApiConfig.getUserProfileEndpoint).replace(queryParameters: {'user_id': userId.toString()});
      final response = await http.get(uri);
      print('Get User Profile API Response: ${response.body}'); // Debugging
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        return {'success': true, 'user': User.fromJson(responseBody['user'])};
      }
      return responseBody;
    } catch (e) {
      print('Get User Profile Network Error: $e'); // Debugging
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  Future<Map<String, dynamic>> getBlockedUsers({required int userId}) async {
    try {
      final uri = Uri.parse(ApiConfig.getBlockedUsersEndpoint).replace(queryParameters: {'user_id': userId.toString()});
      final response = await http.get(uri);
      print('Get Blocked Users API Response: ${response.body}'); // Debugging
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        List<User> blockedUsers = (responseBody['blocked_users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
        return {'success': true, 'blocked_users': blockedUsers};
      }
      return responseBody;
    } catch (e) {
      print('Get Blocked Users Network Error: $e'); // Debugging
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  // NEW METHOD: Fetch reviews for a specific user
  Future<Map<String, dynamic>> getReviewsForUser({required int userId}) async {
    try {
      final uri = Uri.parse(ApiConfig.getReviewsForUserEndpoint).replace(queryParameters: {'user_id': userId.toString()});
      final response = await http.get(uri);
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['success']) {
        List<Review> reviews = (responseBody['reviews'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
        return {'success': true, 'reviews': reviews};
      }
      return responseBody;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}