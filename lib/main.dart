import 'package:flutter/material.dart';
import 'package:hanapp/models/user.dart'; // Make sure this path is correct
import 'package:hanapp/screens/conversations_screen.dart';
import 'package:hanapp/utils/auth_service.dart'; // Make sure this path is correct
import 'package:hanapp/viewmodels/chat_view_model.dart';
import 'package:hanapp/viewmodels/conversations_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Import all your existing screens
import 'package:hanapp/screens/choose_listing_type_screen.dart';
import 'package:hanapp/screens/splash_screen.dart'; // Ensure this is your custom splash screen
import 'package:hanapp/screens/auth/login_screen.dart';
import 'package:hanapp/screens/auth/signup_screen_1.dart';
import 'package:hanapp/screens/auth/signup_screen_2.dart';
import 'package:hanapp/screens/auth/signup_screen_3.dart';
import 'package:hanapp/screens/auth/signup_screen_4.dart';
import 'package:hanapp/screens/auth/email_verification_screen.dart';
import 'package:hanapp/screens/auth/profile_picture_upload_screen.dart';
import 'package:hanapp/screens/role_selection_screen.dart';
import 'package:hanapp/screens/dashboard_screen.dart'; // This might become a placeholder or a wrapper
import 'package:hanapp/screens/lister/lister_dashboard_screen.dart'; // Your Lister/Owner Dashboard
import 'package:hanapp/screens/lister/job_listing_screen.dart';
import 'package:hanapp/screens/lister/listing_details_screen.dart';
import 'package:hanapp/screens/lister/enter_listing_details_screen.dart';
import 'package:hanapp/screens/doer/doer_dashboard_screen.dart'; // Your Doer Dashboard
import 'package:hanapp/screens/view_profile_screen.dart';
import 'package:hanapp/screens/chat_screen.dart';
import 'package:hanapp/screens/lister/anap_listing_map_screen.dart';
import 'package:hanapp/screens/lister/confirm_job_screen.dart';
import 'package:hanapp/screens/lister/rate_job_screen.dart';
import 'package:hanapp/screens/notifications_screen.dart';
import 'package:hanapp/screens/auth/select_location_on_map_screen.dart';
import 'package:hanapp/screens/lister/awaiting_listing_screen.dart';
import 'package:hanapp/screens/profile_settings_screen.dart';
import 'package:hanapp/screens/accounts_screen.dart';
import 'package:hanapp/screens/lister/enter_asap_listing_details_screen.dart';
import 'package:hanapp/screens/community_screen.dart';
import 'package:hanapp/screens/edit_profile_screen.dart';
import 'package:hanapp/screens/hanapp_balance_screen.dart';
import 'package:hanapp/screens/chat_screen_doer.dart'; // NEW: Chat Screen for Doer
import 'package:hanapp/screens/unified_chat_screen.dart'; // NEW: Unified Chat Screen
import 'package:hanapp/viewmodels/review_view_model.dart'; // Make sure this path is correct
import 'package:hanapp/screens/review_screen.dart'; // If you still have this, otherwise remove
import 'package:hanapp/screens/application_details_screen.dart'; // NEW: Import ApplicationDetailsScreen
import 'package:hanapp/screens/map_screen.dart'; // Assuming you have this
import 'package:hanapp/screens/notifications_screen.dart'; // Assuming you have this
import 'package:hanapp/screens/user_profile_screen.dart'; // Assuming you have a user profile screen
import 'package:hanapp/screens/lister/application_overview_screen.dart';


void main() {
  // Ensure Flutter binding is initialized before using any plugins
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve the native splash screen until Flutter is ready to draw its first frame.
  // This helps prevent a blank screen during app startup.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    // MultiProvider is used to provide multiple ChangeNotifierProvider instances
    // to your widget tree. This allows different parts of your app to access
    // shared state (like ChatViewModel and ConversationsViewModel).
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => ConversationsViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()), // <-- ADD THIS LINE
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // This line removes the native splash screen as soon as your Flutter app
    // starts rendering its first widget (which is your SplashScreen).
    // The actual delay for content display and navigation is handled within SplashScreen.
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HANAPP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF141CC9), // HANAPP Blue
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF141CC9),
          foregroundColor: Colors.white, // Set app bar text/icon color
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF141CC9), // HANAPP Blue for buttons
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF141CC9), // HANAPP Blue for text buttons
          ),
        ),
      ),
      // Set your custom SplashScreen as the initial screen of your application.
      // This means SplashScreen will be built and displayed immediately after
      // the native splash screen disappears.
      home: const SplashScreen(),
      // Keep your existing routes for named navigation within the app
      routes: {
        // Remove '/' from here as `home` property handles the initial route
        '/splash': (context) => const SplashScreen(), // If you want to navigate back to splash via route name
        '/login': (context) => const LoginScreen(),
        '/signup1': (context) => const SignupScreen1(),
        '/signup2': (context) => const SignupScreen2(),
        '/signup3': (context) => const SignupScreen3(),
        '/signup4': (context) => const SignupScreen4(),
        '/email_verification': (context) => const EmailVerificationScreen(),
        '/profile_picture_upload': (context) => const ProfilePictureUploadScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/dashboard': (context) => const DashboardScreen(), // This route might be deprecated or used as a generic base if needed
        '/lister_dashboard': (context) => const ListerDashboardScreen(),
        '/doer_dashboard': (context) => const DoerDashboardScreen(),
        '/job_listings': (context) => const JobListingScreen(),
        '/listing_details': (context) => const ListingDetailsScreen(),
        '/enter_listing_details': (context) => const EnterListingDetailsScreen(),
        '/view_profile': (context) => const ViewProfileScreen(),
        '/anap_listing_map': (context) => const AnapListingMapScreen(),
        '/confirm_job': (context) => const ConfirmJobScreen(),
        '/rate_job': (context) => const RateJobScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/select_location_on_map': (context) => const SelectLocationOnMapScreen(),
        '/awaiting_listing': (context) => const AwaitingListingScreen(),
        '/choose_listing_type': (context) => const ChooseListingTypeScreen(),
        '/profile_settings': (context) => const ProfileSettingsScreen(),
        '/accounts': (context) => const AccountsScreen(),
        '/enter_asap_listing_details': (context) => const EnterAsapListingDetailsScreen(),
        '/community': (context) => const CommunityScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/hanapp_balance': (context) => const HanAppBalanceScreen(),
        // Add the route for asap_listing as per the previous suggestion if it's separate from enter_asap_listing_details
        //'/asap_listing': (context) => const AsapListingScreen(),
        '/chat_screen': (context) => const ChatScreen(), // NEW: Route for Chat Screen
        '/chat_screen_doer': (context) => const ChatScreenDoer(), // NEW: Route for Chat Screen (Doer)
        '/unified_chat_screen': (context) => ChangeNotifierProvider(
          create: (context) => ChatViewModel(),
          child: const UnifiedChatScreen(),
        ),
        '/conversations_screen': (context) => ChangeNotifierProvider(
          create: (context) => ConversationsViewModel(),
          child: const ConversationsScreen(),
        ),
        // '/review_screen': (context) => const ReviewScreen(), // Keep if you have a standalone ReviewScreen
        '/listing_details': (context) => const ListingDetailsScreen(), // Keep for generic listing details
        '/map_screen': (context) => const MapScreen(latitude: 0, longitude: 0, title: 'Location'), // Example, adjust if MapScreen needs args
        '/notifications_screen': (context) => const NotificationsScreen(),
        '/user_profile': (context) => const UserProfileScreen(userId: 0), // Example, adjust if UserProfileScreen needs args

        // NEW ROUTE: For Application Details
        '/application_details_screen': (context) => const ApplicationDetailsScreen(listingId: 0), // Dummy listingId, it will be overridden by MaterialPageRoute
        '/map_screen': (context) => const MapScreen(latitude: 0, longitude: 0, title: 'Location'), // Example, adjust if MapScreen needs args
        '/notifications_screen': (context) => const NotificationsScreen(),
        '/application_details_screen': (context) => const ApplicationDetailsScreen(listingId: 0),
        '/application_overview_screen': (context) => const ApplicationOverviewScreen(applicationId: 0),

      },
    );
  }
}
