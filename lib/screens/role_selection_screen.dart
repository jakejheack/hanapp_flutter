// hanapp_flutter/lib/screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:hanapp/utils/auth_service.dart';
import 'package:hanapp/models/user.dart'; // Ensure User model is imported

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  User? _currentUser; // To store the current user

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Load the current user from SharedPreferences
  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService.getUser();
    if (_currentUser == null) {
      // If no user is found, navigate back to login or handle appropriately
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
    setState(() {}); // Trigger rebuild to show user data
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _selectRole(String role) async {
    if (_currentUser == null || _currentUser!.id == null) {
      _showSnackBar('User not logged in or ID missing.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _authService.updateRole(
      _currentUser!.id.toString(), // Pass user ID as string
      role,
    );

    setState(() {
      _isLoading = false;
    });

    if (response['success']) {
      _showSnackBar(response['message']);
      // After successfully setting the role, navigate to the appropriate dashboard
      if (mounted) {
        if (role == 'lister') { // Assuming 'owner' is your 'lister' role
          Navigator.of(context).pushReplacementNamed('/lister_dashboard');
        } else if (role == 'doer') {
          Navigator.of(context).pushReplacementNamed('/doer_dashboard');
        }
      }
    } else {
      _showSnackBar(response['message'], isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // White background as per image
      appBar: AppBar(
        title: const Text('Choose your role'), // Title from image
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Choose your role',
              style: TextStyle(
                fontSize: 28, // Adjusted font size for prominence
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text as per image
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Don't worry, you can switch roles inside",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Grey text as per image
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48), // Increased spacing

            _isLoading
                ? const CircularProgressIndicator()
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lister Role Card
                Expanded(
                  child: _buildRoleCard(
                    context,
                    'Lister',
                    Icons.edit, // Pencil icon from image
                        () => _selectRole('lister'), // Assuming 'owner' is the backend role for Lister
                  ),
                ),
                const SizedBox(width: 24), // Spacing between cards
                // Doer Role Card
                Expanded(
                  child: _buildRoleCard(
                    context,
                    'Doer',
                    Icons.build, // Hammer icon from image
                        () => _selectRole('doer'),
                  ),
                ),
              ],
            ),
            const Spacer(), // Pushes content to top and logo to bottom
            Image.asset(
              'assets/hanapp_logo.jpg', // HANAPP logo from image
              width: 120, // Adjust size as needed
              height: 120,
              // color: Colors.blue, // Assuming blue tint for the logo
            ),
            const SizedBox(height: 24), // Space below logo
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String roleName, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners as per image
      ),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16), // Padding inside card
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor, // Use primary color (HANAPP Blue)
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60, // Icon size
                color: Colors.white, // White icon as per image
              ),
              const SizedBox(height: 16),
              Text(
                roleName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text as per image
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
