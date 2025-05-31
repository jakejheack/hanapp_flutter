class Review {
  final int id;
  final int reviewerId;
  final String reviewerFullName;
  final String? reviewerProfilePictureUrl;
  final int reviewedUserId;
  final int? listingId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerFullName,
    this.reviewerProfilePictureUrl,
    required this.reviewedUserId,
    this.listingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: int.parse(json['id'].toString()),
      reviewerId: int.parse(json['reviewer_id'].toString()),
      reviewerFullName: json['reviewer_name'] as String,
      reviewerProfilePictureUrl: json['reviewer_profile_picture_url'] as String?,
      reviewedUserId: int.parse(json['reviewed_user_id'].toString()),
      listingId: json['listing_id'] != null ? int.parse(json['listing_id'].toString()) : null,
      rating: double.parse(json['rating'].toString()),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerFullName,
      'reviewer_profile_picture_url': reviewerProfilePictureUrl,
      'reviewed_user_id': reviewedUserId,
      'listing_id': listingId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
