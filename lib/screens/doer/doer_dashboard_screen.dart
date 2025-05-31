import 'package:flutter/material.dart';
import 'package:hanapp/models/user.dart';
import 'package:hanapp/utils/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanapp/utils/constants.dart' as Constants; // For colors and padding
import 'package:hanapp/screens/notifications_screen.dart'; // Import NotificationsScreen
import 'package:hanapp/screens/profile_settings_screen.dart'; // Import ProfileSettingsScreen
import 'package:hanapp/screens/lister/job_listing_screen.dart'; // Assuming this can be used for doer job listings too, or a placeholder will be created.
import 'package:hanapp/screens/chat_screen.dart'; // Import ChatScreen
import 'package:hanapp/screens/choose_listing_type_screen.dart';

import '../unified_chat_screen.dart'; // Import ChooseListingTypeScreen

class DoerDashboardScreen extends StatefulWidget {
  const DoerDashboardScreen({super.key});

  @override
  State<DoerDashboardScreen> createState() => _DoerDashboardScreenState();
}

class _DoerDashboardScreenState extends State<DoerDashboardScreen> {
  int _selectedIndex = 0; // To manage selected tab in BottomNavigationBar

  // List of screens for the Doer role's Bottom Navigation Bar
  static final List<Widget> _doerScreens = <Widget>[
    _DoerHomeScreenContent(), // Index 0: Home tab content
    const DoerApplicationsScreen(), // Index 1: Applications tab content
    const NotificationsScreen(), // Index 2: Notifications tab content
    const ProfileSettingsScreen(), // Index 3: Profile tab content
  ];

  // Titles corresponding to each screen/tab
  static const List<String> _screenTitles = <String>[
    'Doer Dashboard',
    '',
    'Notifications',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await AuthService.clearUser();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]), // Dynamic title based on selected tab
        backgroundColor: Constants.primaryColor, // Consistent app bar color
        foregroundColor: Colors.white, // White icons/text for app bar
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.chat_bubble_outline), // Chat icon
        //   onPressed: () {
        //     // Navigate to a screen listing owners they've chatted with
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const OwnerChatListScreen()), // New screen for owner chat list
        //     );
        //   },
        //   tooltip: 'Chats with Doers',
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline), // Chat icon
            onPressed: () {
              // Navigate to the new ConversationsScreen
              Navigator.of(context).pushNamed('/conversations_screen');
            },
            tooltip: 'Chats',
          ),
        ],
      ),
      body: _doerScreens.elementAt(_selectedIndex), // Display the selected screen content
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // The plus button for a Doer might be to "Find New Jobs" or "Go Online".
          // For now, it navigates to ChooseListingTypeScreen, which might need adjustment
          // based on actual Doer flow.
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseListingTypeScreen()));
          Navigator.of(context).pushNamed('/job_listings');
        },
        backgroundColor: Constants.primaryColor, // HANAPP Blue
        shape: const CircleBorder(),
        child: const Icon(Icons.search, color: Colors.white, size: 35),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Constants.primaryColor, // Consistent bottom app bar color
        shape: const CircularNotchedRectangle(), // Shape for FAB notch
        notchMargin: 8.0, // Margin for FAB notch
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home),
              color: _selectedIndex == 0 ? Colors.yellow.shade700 : Colors.white70,
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.assignment), // Applications tab icon
              color: _selectedIndex == 1 ? Colors.yellow.shade700 : Colors.white70,
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), // Space for the Floating Action Button
            IconButton(
              icon: const Icon(Icons.notifications),
              color: _selectedIndex == 2 ? Colors.yellow.shade700 : Colors.white70, // Index 2 in _doerScreens
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              color: _selectedIndex == 3 ? Colors.yellow.shade700 : Colors.white70, // Index 3 in _doerScreens
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}

// --- New Widget for the Doer Home Screen Content ---
class _DoerHomeScreenContent extends StatefulWidget {
  @override
  State<_DoerHomeScreenContent> createState() => _DoerHomeScreenContentState();
}

class _DoerHomeScreenContentState extends State<_DoerHomeScreenContent> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService.getUser();
    setState(() {});
  }

  // Helper method to build quick action cards
  Widget _buildQuickActionCard(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Constants.primaryColor), // Use Constants.primaryColor
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Section
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: _currentUser!.profilePictureUrl != null && _currentUser!.profilePictureUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(_currentUser!.profilePictureUrl!) as ImageProvider<Object>?
                    : const AssetImage('assets/default_profile.png') as ImageProvider<Object>?,
                child: (_currentUser!.profilePictureUrl == null || _currentUser!.profilePictureUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${_currentUser!.fullName}!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Role: ${_currentUser!.role ?? 'Not set'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dashboard Image/Banner
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/dashboard_image.png'), // Ensure this asset exists
                fit: BoxFit.cover,
                // onError: (context, error, stackTrace) {
                //   // Fallback for missing image asset
                //   debugPrint('Error loading image: $error');
                // },
              ),
            ),
            child: const Center(
              child: Text(
                'Find the help you need!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions/Categories
          const Text(
            'Doer Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildQuickActionCard(Icons.search, 'Browse Listings', () {
                // Navigate to a screen where doers can browse available job listings
                Navigator.of(context).pushNamed('/job_listings'); // Assuming this route exists
              }),
              _buildQuickActionCard(Icons.assignment_ind, 'My Applications', () {
                // Navigate to the DoerApplicationsScreen
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DoerApplicationsScreen()));
              }),
              _buildQuickActionCard(Icons.star, 'Favorite Lister', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favorite Lister functionality coming soon!')),
                );
              }),
              _buildQuickActionCard(Icons.rate_review, 'My Reviews', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('My Reviews functionality coming soon!')),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Placeholder for DoerApplicationsScreen ---
class DoerApplicationsScreen extends StatelessWidget {
  const DoerApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'This screen will show your job applications.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Placeholder for OwnerChatListScreen (for Doer to chat with Owners) ---
class OwnerChatListScreen extends StatelessWidget {
  const OwnerChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats with Doers'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Lists doer you\'ve been chatting with',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Example: Navigate to a specific chat, or show a list of chats
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UnifiedChatScreen()));
              },
              child: const Text('View Sample Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
