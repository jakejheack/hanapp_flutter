import 'package:hanapp/models/review.dart';

class User {
  final int id;
  String fullName; // Changed to non-final
  String email; // Changed to non-final
  String? role;
  final bool? isVerified;
  String? profilePictureUrl;
  final double? averageRating; // Make nullable
  final int? reviewCount; // Make nullable
  String? addressDetails; // Changed to non-final
  double? latitude; // Changed to non-final
  double? longitude; // Changed to non-final
  String? contactNumber; // NEW: Added contactNumber
  final int totalReviews; // NEW: Total number of reviews
  final List<Review>? reviews; // NEW: List of reviews for this user

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.role,
    this.isVerified,
    this.profilePictureUrl,
    this.averageRating = 0.0,
    this.reviewCount,
    this.addressDetails,
    this.latitude,
    this.longitude,
    this.contactNumber, // NEW
    this.totalReviews = 0,    // Default value
    this.reviews, // Initialize reviews
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<Review>? userReviews;
    if (json['reviews'] != null) { // Assuming the backend sends a 'reviews' array
      userReviews = (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList();
    }
    return User(
      id: int.parse(json['id'].toString()),
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'],
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      profilePictureUrl: json['profile_picture_url'],
      averageRating: json['average_rating'] != null ? double.parse(json['average_rating'].toString()) : 0.0,
      totalReviews: json['total_reviews'] != null ? int.parse(json['total_reviews'].toString()) : 0,
      reviewCount: json['review_count'] as int?, // Handle null
      addressDetails: json['address_details'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      contactNumber: json['contact_number'], // NEW
      reviews: userReviews,
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'is_verified': isVerified,
      'profile_picture_url': profilePictureUrl,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'address_details': addressDetails,
      'latitude': latitude,
      'longitude': longitude,
      'contact_number': contactNumber, // NEW
      'total_reviews': totalReviews,
      'reviews': reviews?.map((e) => e.toJson()).toList(),
    };
  }
}