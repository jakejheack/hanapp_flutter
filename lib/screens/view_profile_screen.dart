import 'package:flutter/material.dart';
import 'package:hanapp/utils/user_service.dart';
import 'package:hanapp/models/user.dart';
import 'package:hanapp/models/review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final UserService _userService = UserService();
  User? _profileUser;
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = ModalRoute.of(context)!.settings.arguments as int;
    _fetchUserProfile(userId);
    _fetchUserReviews(userId);
  }

  Future<void> _fetchUserProfile(int userId) async {
    setState(() {
      _isLoading = true;
    });
    final response = await _userService.getUserProfile(userId);
    setState(() {
      _isLoading = false;
      if (response['success']) {
        _profileUser = response['user'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user profile: ${response['message']}')),
        );
      }
    });
  }

  Future<void> _fetchUserReviews(int userId) async {
    final response = await _userService.getUserReviews(userId);
    if (response['success']) {
      setState(() {
        _reviews = response['reviews'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reviews: ${response['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profileUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Profile...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_profileUser!.fullName),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: _profileUser!.profilePictureUrl != null && _profileUser!.profilePictureUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(_profileUser!.profilePictureUrl!) as ImageProvider<Object>?
                  : null,
              child: (_profileUser!.profilePictureUrl == null || _profileUser!.profilePictureUrl!.isEmpty)
                  ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _profileUser!.fullName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _profileUser!.email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${_profileUser!.role ?? 'Not Set'}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Ratings display
            if (_profileUser!.averageRating != null && _profileUser!.reviewCount != null)
              Column(
                children: [
                  RatingBarIndicator(
                    rating: _profileUser!.averageRating!,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 25.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_profileUser!.averageRating!.toStringAsFixed(1)} average from ${_profileUser!.reviewCount} reviews',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            if (_reviews.isEmpty) const Text('No reviews yet.') else ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                var rating;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: review.reviewerProfilePictureUrl != null && review.reviewerProfilePictureUrl!.isNotEmpty
                                  ? CachedNetworkImageProvider(review.reviewerProfilePictureUrl!) as ImageProvider<Object>?
                                  : null,
                              child: (review.reviewerProfilePictureUrl == null || review.reviewerProfilePictureUrl!.isEmpty)
                                  ? const Icon(Icons.person, size: 25)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                review.reviewerFullName ?? 'Anonymous',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 18.0,
                              direction: Axis.horizontal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(review.comment ?? 'No comment provided.'),
                        const SizedBox(height: 4),
                        Text(
                          '${review.createdAt.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}