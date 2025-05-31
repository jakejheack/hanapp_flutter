import 'package:flutter/material.dart';
import 'package:hanapp/utils/auth_service.dart'; // Assuming this exists
import 'package:hanapp/screens/components/custom_button.dart'; // Our custom button
import 'package:hanapp/screens/components/custom_text_field.dart'; // Our custom text field
import 'package:hanapp/utils/constants.dart'; // Our constants for colors and padding
import 'package:hanapp/models/user.dart'; // Import the User model

// Import your dashboard screens and role selection screen
import 'package:hanapp/screens/lister/lister_dashboard_screen.dart';
import 'package:hanapp/screens/doer/doer_dashboard_screen.dart';
import 'package:hanapp/screens/role_selection_screen.dart';

import '../../utils/constants.dart' as Constants;


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Assuming AuthService is correctly implemented
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Added for form validation

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) { // Validate form before login
      setState(() {
        _isLoading = true;
      });

      // Assuming loginUser returns a Map with 'success' and 'message'
      final response = await _authService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        _showSnackBar(response['message']);

        // --- NEW LOGIC FOR ROLE-BASED NAVIGATION ---
        User? loggedInUser = await AuthService.getUser(); // Retrieve the logged-in user's data

        if (mounted) { // Check if the widget is still in the widget tree
          if (loggedInUser != null && (loggedInUser.role == null || loggedInUser.role!.isEmpty)) {
            // If user has no role set (or it's empty), navigate to role selection
            Navigator.of(context).pushReplacementNamed('/role_selection');
          } else if (loggedInUser != null && loggedInUser.role == 'lister') {
            // If role is 'owner' (lister), navigate to Lister Dashboard
            Navigator.of(context).pushReplacementNamed('/lister_dashboard');
          } else if (loggedInUser != null && loggedInUser.role == 'doer') {
            // If role is 'doer', navigate to Doer Dashboard
            Navigator.of(context).pushReplacementNamed('/role_selection');
          } else {
            // Fallback for any unexpected role or data issue, go to a generic dashboard or login
            Navigator.of(context).pushReplacementNamed('/dashboard'); // Or '/login'
          }
        }
        // --- END NEW LOGIC ---

      } else {
        _showSnackBar(response['message'], isError: true);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow
        padding: Constants.screenPadding, // Use consistent padding from constants.dart
        child: Form( // Wrap with Form for validation
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
            children: [
              const SizedBox(height: 50), // Space from top/app bar

              const Text(
                'LOG IN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Constants.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30), // Space after LOG IN title

              CustomTextField(
                labelText: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Space between email and password fields

              CustomTextField(
                labelText: 'Password',
                hintText: 'Enter your password',
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8), // Space before forgot password

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password navigation
                    _showSnackBar('Forgot password not implemented yet.', isError: true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Constants.primaryColor, // Blue text
                  ),
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(fontSize: 14), // Smaller font as in image
                  ),
                ),
              ),
              const SizedBox(height: 24), // Space before continue button

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                text: 'Continue',
                onPressed: _login,
                color: Constants.primaryColor, // Solid blue background
                textColor: Constants.buttonTextColor, // White text
                borderRadius: 25.0, // More rounded corners for this button
                height: 50.0, // Consistent height
              ),
              const SizedBox(height: 16), // Space after continue button

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/signup1'); // Assuming '/signup1' is your first signup screen route
                },
                style: TextButton.styleFrom(
                  foregroundColor: Constants.textColor, // Default text color
                ),
                child: RichText(
                  text: TextSpan(
                    text: "Don't have a HANAPP account? ",
                    style: const TextStyle(color: Constants.textColor, fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign up here',
                        style: const TextStyle(
                          color: Constants.primaryColor, // Blue for "Sign up here"
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24), // Space before social logins

              // Social login buttons (styled as outlined buttons)
              CustomButton(
                text: 'G-OOGLE',
                onPressed: () { _showSnackBar('Google login not implemented yet.', isError: true); },
                color: Colors.white, // White background
                textColor: Constants.socialButtonTextColor, // Black text
                borderSide: const BorderSide(color: Constants.socialButtonBorderColor, width: 1.0), // Blue border
                borderRadius: 8.0, // Standard rounded corners
                height: 50.0,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'F-ACEBOOK',
                onPressed: () { _showSnackBar('Facebook login not implemented yet.', isError: true); },
                color: Colors.white, // White background
                textColor: Constants.socialButtonTextColor, // Black text
                borderSide: const BorderSide(color: Constants.socialButtonBorderColor, width: 1.0), // Blue border
                borderRadius: 8.0, // Standard rounded corners
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}