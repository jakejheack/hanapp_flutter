import 'package:flutter/material.dart';
import 'package:hanapp/models/user.dart';
import 'package:hanapp/utils/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? _currentUser;
  int _selectedIndex = 0; // To manage selected tab in BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService.getUser();
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0:
      // Home/Dashboard - already here
        break;
      case 1:
      // Applications/Jobs - navigate to appropriate screen
        Navigator.of(context).pushNamed('/job_listings');
        break;
      case 3:
      // Notifications
        Navigator.of(context).pushNamed('/notifications');
        break;
      case 4:
      // Profile
        if (_currentUser != null) {
          Navigator.of(context).pushNamed('/profile_settings'); // Navigates to the new ProfileSettingsScreen
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.clearUser();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            if (_currentUser != null)
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
                  image: AssetImage('assets/dashboard_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Text(
                  'Need help with something?',
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

            // Quick Actions/Categories (placeholders)
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQuickActionCard(Icons.work, 'Find Jobs', () {
                  Navigator.of(context).pushNamed('/job_listings');
                }),
                _buildQuickActionCard(Icons.list_alt, 'My Listings', () {
                  Navigator.of(context).pushNamed('/lister_dashboard');
                }),
                _buildQuickActionCard(Icons.chat, 'Messages', () {
                  Navigator.of(context).pushNamed('/chat_list');
                }),
                _buildQuickActionCard(Icons.history, 'History', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History not implemented yet.')),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the new screen when plus button is pressed
          Navigator.of(context).pushNamed('/choose_listing_type');
        },
        backgroundColor: const Color(0xFF141CC9),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF141CC9), // Set background color to the desired blue
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              color: _selectedIndex == 0 ? Colors.yellow.shade700 : Colors.white70, // Yellow indicator
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.assignment),
              color: _selectedIndex == 1 ? Colors.yellow.shade700 : Colors.white70, // Yellow indicator
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), // The space for the FAB
            IconButton(
              icon: Icon(Icons.notifications),
              color: _selectedIndex == 3 ? Colors.yellow.shade700 : Colors.white70, // Yellow indicator
              onPressed: () => _onItemTapped(3),
            ),
            IconButton(
              icon: Icon(Icons.person),
              color: _selectedIndex == 4 ? Colors.yellow.shade700 : Colors.white70, // Yellow indicator
              onPressed: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }

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
              Icon(icon, size: 40, color: const Color(0xFF141CC9)),
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
}