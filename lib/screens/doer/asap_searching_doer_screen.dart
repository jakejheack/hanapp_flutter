import 'package:flutter/material.dart';
import 'package:hanapp/utils/constants.dart';

import '../../utils/constants.dart' as Constants; // For colors and padding

class AsapSearchingDoerScreen extends StatefulWidget {
  final Map<String, dynamic> listingData;

  const AsapSearchingDoerScreen({super.key, required this.listingData});

  @override
  State<AsapSearchingDoerScreen> createState() => _AsapSearchingDoerScreenState();
}

class _AsapSearchingDoerScreenState extends State<AsapSearchingDoerScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate searching for a doer
    _startSearching();
  }

  void _startSearching() async {
    // In a real app, this would involve:
    // 1. Making an API call to find available doers.
    // 2. Potentially showing a real-time map with doers.
    // 3. Handling doer acceptance/rejection.
    await Future.delayed(const Duration(seconds: 5)); // Simulate search time

    if (mounted) {
      // After simulating search, navigate to a confirmation or status screen
      // For now, let's just pop back or go to a generic success screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doer found! (Simulated)')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the main dashboard
      // Or navigate to a specific screen like JobListingScreen to see the new job
      // Navigator.pushReplacementNamed(context, '/job_listings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Searching for Doer'),
        automaticallyImplyLeading: false, // Prevent back button during search
      ),
      body: Padding(
        padding: Constants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
            ),
            const SizedBox(height: 32),
            Text(
              'Searching for a doer for "${widget.listingData['title']}"...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Please wait while we find the best doer near your location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 48),
            // You might add a cancel button here
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Allow user to cancel search
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel Search'),
            ),
          ],
        ),
      ),
    );
  }
}
