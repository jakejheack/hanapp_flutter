// hanapp_flutter/lib/viewmodels/review_view_model.dart
import 'package:flutter/material.dart';
import 'package:hanapp/utils/listing_service.dart'; // Ensure correct path
import 'package:hanapp/utils/auth_service.dart'; // For fetching user details (if needed)
import 'package:hanapp/models/user.dart'; // For User model (if needed)

class ReviewViewModel extends ChangeNotifier {
  final ListingService _listingService = ListingService();
  final AuthService _authService = AuthService(); // For fetching user details

  // You might not need _reviewedUserName here if it's passed directly to the dialog
  // But keeping it for consistency if other parts of the app use it.
  String? _reviewedUserName;
  String? get reviewedUserName => _reviewedUserName;

  Future<void> fetchReviewedUserName(int reviewedUserId) async {
    final response = await _authService.getUserProfileById(userId: reviewedUserId);
    if (response['success']) {
      _reviewedUserName = (response['user'] as User).fullName;
    } else {
      _reviewedUserName = 'Unknown User'; // Fallback
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitReview({
    required int reviewerId,
    required int reviewedUserId,
    int? listingId,
    required double rating,
    String? comment,
  }) async {
    print('ReviewViewModel: Submitting review...');
    print('  Reviewer ID: $reviewerId');
    print('  Reviewed User ID: $reviewedUserId');
    print('  Listing ID: $listingId');
    print('  Rating: $rating');
    print('  Comment: $comment');

    // Call the ListingService to send the review to the backend
    final response = await _listingService.submitReview(
      reviewerId: reviewerId,
      reviewedUserId: reviewedUserId,
      listingId: listingId,
      rating: rating,
      comment: comment,
    );

    if (response['success']) {
      print('ReviewViewModel: Review submitted successfully: ${response['message']}');
    } else {
      print('ReviewViewModel: Failed to submit review: ${response['message']}');
    }
    return response;
  }
}
