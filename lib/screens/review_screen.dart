import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hanapp/viewmodels/review_view_model.dart'; // You'll need to create this

class ReviewScreen extends StatefulWidget {
  final int reviewerId;
  final int reviewedUserId;
  final int? listingId;
  final String? listingTitle;

  const ReviewScreen( {
    super.key,
    required this.reviewerId,
    required this.reviewedUserId,
    this.listingId,
    this.listingTitle,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
        backgroundColor: const Color(0xFF141CC9),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviewing ${widget.listingTitle ?? 'Job'} with ${Provider.of<ReviewViewModel>(context, listen: false).reviewedUserName ?? 'User'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Rating:', style: TextStyle(fontSize: 16)),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.round().toString(),
              onChanged: (newRating) {
                setState(() {
                  _rating = newRating;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
                  final response = await reviewViewModel.submitReview(
                    reviewerId: widget.reviewerId,
                    reviewedUserId: widget.reviewedUserId,
                    listingId: widget.listingId,
                    rating: _rating,
                    comment: _commentController.text.trim(),
                  );

                  if (response['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'])),
                    );
                    Navigator.of(context).pop(); // Go back to chat screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit review: ${response['message']}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF141CC9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Submit Review', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
