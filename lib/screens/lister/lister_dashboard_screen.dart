import 'package:flutter/material.dart';
import 'package:hanapp/screens/lister/job_listing_screen.dart'; // Your existing job listings screen
import 'package:hanapp/screens/choose_listing_type_screen.dart'; // Corrected import: Screen to post new jobs
import 'package:hanapp/screens/profile_settings_screen.dart'; // Profile settings shared
import 'package:hanapp/screens/notifications_screen.dart'; // Notifications screen
import 'package:hanapp/screens/conversations_screen.dart'; // NEW: Import ConversationsScreen
import 'package:hanapp/screens/unified_chat_screen.dart'; // Unified chat screen
import 'package:hanapp/utils/constants.dart' as Constants; // For colors and padding
import 'package:hanapp/utils/auth_service.dart'; // Import AuthService for logout

class ListerDashboardScreen extends StatefulWidget {
  const ListerDashboardScreen({super.key});

  @override
  State<ListerDashboardScreen> createState() => _ListerDashboardScreenState();
}

class _ListerDashboardScreenState extends State<ListerDashboardScreen> {
  int _selectedIndex = 0; // To control BottomNavigationBar

  // List of screens for the Owner/Lister role's Bottom Navigation Bar
  static final List<Widget> _ownerScreens = <Widget>[
    _ListerHomeScreenContent(), // Index 0: Home tab content
    const JobListingScreen(), // Index 1: Jobs tab content
    const NotificationsScreen(), // Index 2: Notifications tab content
    const ProfileSettingsScreen(), // Index 3: Profile tab content
  ];

  // Titles corresponding to each screen/tab
  static const List<String> _screenTitles = <String>[
    'Lister',
    'Jobs',
    'Notifications',
    'Profile',
  ];

  void _onItemTapped(int index) {
    // Adjust index for _ownerScreens list as BottomAppBar has a FAB space
    int actualScreenIndex = index;
    if (index == 3) { // Notifications icon (index 3 in BottomAppBar row)
      actualScreenIndex = 2; // Corresponds to NotificationsScreen in _ownerScreens
    } else if (index == 4) { // Profile icon (index 4 in BottomAppBar row)
      actualScreenIndex = 3; // Corresponds to ProfileSettingsScreen in _ownerScreens
    }

    setState(() {
      _selectedIndex = actualScreenIndex;
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
      body: _ownerScreens.elementAt(_selectedIndex), // Display the selected screen content
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
              icon: const Icon(Icons.check_circle_outline), // Jobs tab icon
              color: _selectedIndex == 1 ? Colors.yellow.shade700 : Colors.white70,
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48), // Space for the Floating Action Button
            IconButton(
              icon: const Icon(Icons.notifications),
              color: _selectedIndex == 2 ? Colors.yellow.shade700 : Colors.white70, // Corrected index for Notifications
              onPressed: () => _onItemTapped(3), // Pass original index for logic
            ),
            IconButton(
              icon: const Icon(Icons.person),
              color: _selectedIndex == 3 ? Colors.yellow.shade700 : Colors.white70, // Corrected index for Profile
              onPressed: () => _onItemTapped(4), // Pass original index for logic
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // The plus button for posting a new job listing
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseListingTypeScreen()));
        },
        backgroundColor: Constants.primaryColor, // HANAPP Blue
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
    );
  }
}

// --- Existing Widget for the Lister Home Screen Content (no changes) ---
class _ListerHomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Constants.screenPadding, // Use consistent padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Announcement/Promo Code Area
          Card(
            margin: const EdgeInsets.only(bottom: 24.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                // Navigate to a screen showing announcement/promo code details
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnnouncementDetailsScreen()),
                );
              },
              child: Container(
                height: 120, // Height from image
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background as per image
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Announcement Area', // Text from image
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'announcement/promo code of the day', // Subtext from image
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // "Need help with something?" List it here on HanApp!
          Card(
            margin: const EdgeInsets.only(bottom: 24.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                // Navigate to the screen for posting a new job
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChooseListingTypeScreen()),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      'assets/hanapp_logo.jpg', // Placeholder image from the image
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Need help with something?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'List it here on HanApp!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Auto video play, promotions and tutorial
          Card(
            margin: const EdgeInsets.only(bottom: 24.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 200, // Example height for video player
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black, // Dark background for video area
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_fill, size: 60, color: Colors.white70),
                    SizedBox(height: 16),
                    Text(
                      'Auto video play, promotions and tutorial', // Text from image
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Existing Placeholder Screen for Announcement Details (no changes) ---
class AnnouncementDetailsScreen extends StatelessWidget {
  const AnnouncementDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement/Promo Code'),
      ),
      body: const Padding(
        padding: Constants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Announcement & Promo Code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Here you can display the full details of the announcement or the daily promo code. This might include terms and conditions, validity dates, etc.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Promo Code: HANAPP2024',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            Text(
              'Valid until: December 31, 2024',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
