// hanapp_flutter/lib/screens/profile_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:hanapp/models/user.dart'; // Make sure this path is correct
import 'package:hanapp/utils/auth_service.dart'; // Make sure this path is correct
import 'package:cached_network_image/cached_network_image.dart'; // For profile picture

// Import your dashboards
import 'package:hanapp/screens/lister/lister_dashboard_screen.dart'; // Import ListerDashboardScreen
import 'package:hanapp/screens/doer/doer_dashboard_screen.dart';   // Import DoerDashboardScreen


class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  User? _currentUser;
  bool _isLoadingRoleSwitch = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Load user data when the screen initializes
  }

  // Loads the current user from local storage
  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService.getUser();
    if (_currentUser == null) {
      // If no user is found, navigate back to login
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
    setState(() {}); // Update the UI once user data is loaded
  }

  // Helper to show snackbar messages
  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.green,
      ),
    );
  }

  // Logic for switching the user's role
  Future<void> _switchRole() async {
    if (_currentUser == null || _currentUser!.id == null) {
      _showSnackBar('User not logged in or ID missing.', backgroundColor: Colors.red);
      return;
    }

    setState(() {
      _isLoadingRoleSwitch = true; // Show loading indicator
    });

    // Determine the new role based on the current role
    String newRole = (_currentUser!.role == 'lister') ? 'doer' : 'lister'; // Assuming 'owner' is 'lister'

    // Call the AuthService to update the role in the backend AND locally
    final response = await _authService.updateRole(
      _currentUser!.id.toString(), // Pass user ID as string
      newRole,
    );

    setState(() {
      _isLoadingRoleSwitch = false; // Hide loading indicator
    });

    if (response['success']) {
      // After successful role switch, reload the current user from local storage
      // This is crucial because AuthService.updateRole updates it locally.
      await _loadCurrentUser();

      _showSnackBar('Role switched to ${newRole.toUpperCase()}!', backgroundColor: Colors.yellow.shade700);

      // ***** THIS IS THE KEY CHANGE *****
      // Navigate to the appropriate dashboard based on the NEW role
      if (mounted) {
        if (_currentUser!.role == 'lister') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ListerDashboardScreen()), // Go to Lister Dashboard
                (Route<dynamic> route) => false, // Remove all previous routes
          );
        } else if (_currentUser!.role == 'doer') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DoerDashboardScreen()), // Go to Doer Dashboard
                (Route<dynamic> route) => false, // Remove all previous routes
          );
        }
      }
    } else {
      _showSnackBar('Failed to switch role: ${response['message']}', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if current user data is not yet loaded
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Determine the image provider for the profile picture
    ImageProvider<Object>? imageProvider;
    if (_currentUser!.profilePictureUrl != null && _currentUser!.profilePictureUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(_currentUser!.profilePictureUrl!);
    } else {
      imageProvider = const AssetImage('assets/default_profile.png');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text('Profile Settings'),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF141CC9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: imageProvider,
                    child: (_currentUser!.profilePictureUrl == null || _currentUser!.profilePictureUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser!.fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          _currentUser!.addressDetails ?? 'Location not set',
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current Role: ${_currentUser!.role?.toUpperCase() ?? 'Not set'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _isLoadingRoleSwitch
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.sync_alt, color: Colors.white, size: 30),
                      onPressed: _switchRole, // This is the button that triggers the role switch
                      tooltip: 'Switch Role to ${_currentUser!.role == 'lister' ? 'Doer' : 'Lister'}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ... (other settings tiles like Community, Edit Profile, HanApp Balance, etc.)
            _buildSettingsTile(
              icon: Icons.people,
              title: 'Community',
              onTap: () { Navigator.of(context).pushNamed('/community');
                },
            ),
            _buildSettingsTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                Navigator.of(context).pushNamed('/edit_profile');
                },
            ),
            _buildSettingsTile(
              icon: Icons.account_balance_wallet,
              title: 'HanApp Balance',
              onTap: () {
                Navigator.of(context).pushNamed('/hanapp_balance');
                },
            ),
            _buildSettingsTile(
              icon: Icons.verified_user,
              title: 'Verification',
              onTap: () { _showSnackBar('Verification not implemented yet.'); },
            ),
            _buildSettingsTile(
              icon: Icons.account_circle,
              title: 'Accounts',
              onTap: () {
                Navigator.of(context).pushNamed('/accounts');
              },
            ),
            _buildSettingsTile(
              icon: Icons.security,
              title: 'Security',
              onTap: () { _showSnackBar('Security settings not implemented yet.'); },
            ),
            _buildSettingsTile(
              icon: Icons.description,
              title: 'Terms & Conditions (coming soon...)',
              onTap: () { _showSnackBar('Terms & Conditions (COMING SOON.).'); },
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy (coming soon...)',
              onTap: () { _showSnackBar('Privacy Policy (COMING SOON.).'); },
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                await AuthService.clearUser();
                if (mounted) Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for consistent settings tile appearance
  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF34495E)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}