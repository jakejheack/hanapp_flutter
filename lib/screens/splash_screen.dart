// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:hanapp/models/user.dart'; // Ensure correct path
import 'package:hanapp/utils/auth_service.dart'; // Ensure correct path
import 'package:hanapp/screens/auth/login_screen.dart'; // Ensure correct path
import 'package:hanapp/screens/role_selection_screen.dart'; // Ensure correct path
import 'package:hanapp/screens/lister/lister_dashboard_screen.dart'; // Ensure correct path
import 'package:hanapp/screens/doer/doer_dashboard_screen.dart'; // Ensure correct path

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  // This function will check the user's authentication status and role
  // and then navigate to the appropriate screen.
  Future<void> _checkUserAndNavigate() async {
    // Optional: Add a delay to show your splash screen for a minimum duration
    await Future.delayed(const Duration(seconds: 2)); // Adjust as needed

    final user = await AuthService.getUser(); // Fetch user data

    // Ensure the widget is still mounted before performing navigation
    if (!mounted) return;

    if (user != null) {
      // User is logged in
      if (user.role == 'lister') {
        Navigator.pushReplacementNamed(context, '/lister_dashboard');
      } else if (user.role == 'doer') {
        Navigator.pushReplacementNamed(context, '/doer_dashboard');
      } else {
        // User exists but role is not defined or unexpected, send to role selection
        Navigator.pushReplacementNamed(context, '/role_selection');
      }
    } else {
      // No user found, navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This is what your splash screen will look like while loading.
    // You can replace CircularProgressIndicator with your app logo,
    // a custom animation, or any other splash screen design.
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your app logo or custom splash animation
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF141CC9)), // HANAPP Blue
            ),
            SizedBox(height: 20),
            Text(
              'Loading HanApp...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF141CC9), // HANAPP Blue
              ),
            ),
          ],
        ),
      ),
    );
  }
}