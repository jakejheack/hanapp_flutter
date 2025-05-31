// lib/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSocialButton(context, 'Join Facebook Group', Icons.facebook, 'https://facebook.com/groups/yourgroup'), // Icon from image
            _buildSocialButton(context, 'Like Facebook Page', Icons.facebook, 'https://facebook.com/yourpage'), // Icon from image
            _buildSocialButton(context, 'Follow Instagram', Icons.camera_alt, 'https://instagram.com/yourinstagram'), // Icon from image
            _buildSocialButton(context, 'Follow TikTok', Icons.tiktok, 'https://tiktok.com/@yourtiktok'), // Icon from image (requires custom icon or different approach)
            _buildSocialButton(context, 'Subscribe YouTube Channel', Icons.play_arrow, 'https://youtube.com/yourchannel'), // Icon from image
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, String text, IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => _launchURL(url),
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50), // Full width button
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.grey),
          ),
          alignment: Alignment.centerLeft, // Align content to left
        ),
      ),
    );
  }
}

// Note: For TikTok icon, you might need to use a custom icon font or an image asset if not available directly in Icons.