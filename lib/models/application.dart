import 'package:hanapp/models/listing.dart'; // Ensure correct path
import 'package:hanapp/models/user.dart'; // Ensure correct path

class Application {
  final int id;
  final int listingId;
  final int applicantId;
  final String status; // e.g., 'pending', 'accepted', 'rejected', 'hired', 'ongoing', 'completed_by_doer', 'completed'
  final DateTime appliedAt;
  final Listing? listing; // Details of the listing
  final User? applicant; // Details of the applicant
  final String? message; // NEW: Message from the applicant

  Application({
    required this.id,
    required this.listingId,
    required this.applicantId,
    required this.status,
    required this.appliedAt,
    this.listing,
    this.applicant,
    this.message,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: int.parse(json['id'].toString()),
      listingId: int.parse(json['listing_id'].toString()),
      applicantId: int.parse(json['applicant_id'].toString()),
      status: json['status'] as String,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      listing: json['listing'] != null ? Listing.fromJson(json['listing']) : null,
      applicant: json['applicant'] != null ? User.fromJson(json['applicant']) : null,
      message: json['message_text'], // Map message_text from backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'applicant_id': applicantId,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'listing': listing?.toJson(),
      'applicant': applicant?.toJson(),
      'message_text': message,
    };
  }
}
