import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hanapp/screens/components/custom_button.dart'; // Ensure correct path
import 'package:hanapp/utils/auth_service.dart'; // Ensure correct path
import 'package:hanapp/utils/location_service.dart'; // Ensure correct path
import 'package:hanapp/models/user.dart'; // Ensure correct path
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanapp/screens/select_location_on_map_screen.dart'; // Import the new map screen

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  XFile? _pickedXFile;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();
  // LocationService might not be directly used here anymore if location selection is via map
  // final LocationService _locationService = LocationService();
  User? _currentUser;
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndPopulateFields();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserAndPopulateFields() async {
    _currentUser = await AuthService.getUser();
    if (_currentUser == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }
    setState(() {
      _fullNameController.text = _currentUser!.fullName;
      _emailController.text = _currentUser!.email;
      _contactNumberController.text = _currentUser!.contactNumber ?? '';
      _addressController.text = _currentUser!.addressDetails ?? '';
      _latitude = _currentUser!.latitude;
      _longitude = _currentUser!.longitude;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedXFile = pickedFile;
      });
    }
  }

  Future<void> _selectLocationOnMap() async {
    // Navigate to the new SelectLocationOnMapScreen
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectLocationOnMapScreen(
          initialLatitude: _latitude, // Pass current saved location if available
          initialLongitude: _longitude,
          initialAddress: _addressController.text,
        ),
      ),
    ) as Map<String, dynamic>?; // Cast the result to Map<String, dynamic>

    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _addressController.text = result['address'];
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_currentUser == null || _currentUser!.id == null) {
      _showSnackBar('User not logged in.', isError: true);
      return;
    }

    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _latitude == null ||
        _longitude == null) {
      _showSnackBar('Please fill all required fields and select a location.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.updateUserProfile(
        userId: _currentUser!.id,
        fullName: _fullNameController.text,
        email: _emailController.text,
        contactNumber: _contactNumberController.text,
        addressDetails: _addressController.text,
        latitude: _latitude,
        longitude: _longitude,
        profilePictureFile: _pickedXFile,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        _showSnackBar(response['message']);
        // Reload user data to reflect changes
        await AuthService.getUser(); // This will refresh the local stored user
        if (mounted) {
          Navigator.of(context).pop(); // Go back to profile settings
        }
      } else {
        _showSnackBar('Failed to update profile: ${response['message']}', isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error updating profile: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    ImageProvider<Object>? imageProvider;
    if (_pickedXFile != null) {
      if (kIsWeb) {
        imageProvider = NetworkImage(_pickedXFile!.path);
      } else {
        imageProvider = FileImage(File(_pickedXFile!.path));
      }
    } else if (_currentUser!.profilePictureUrl != null && _currentUser!.profilePictureUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(_currentUser!.profilePictureUrl!);
    } else {
      imageProvider = const AssetImage('assets/default_profile.png');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF141CC9), // HANAPP Blue
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageProvider,
                child: _pickedXFile == null && (_currentUser!.profilePictureUrl == null || _currentUser!.profilePictureUrl!.isEmpty)
                    ? Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.grey[600],
                )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactNumberController,
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              readOnly: true, // Make it read-only as location is selected from map
              decoration: InputDecoration(
                labelText: 'Saved Address',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _selectLocationOnMap, // This will open the map screen
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              text: 'Save Changes',
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
