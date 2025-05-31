import 'package:flutter/material.dart';
import 'package:hanapp/screens/components/custom_button.dart';
import 'package:hanapp/utils/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('email')) {
      _email = args['email'];
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _verifyEmail() async {
    if (_email.isEmpty || _codeController.text.isEmpty) {
      _showSnackBar('Please enter the OTP and ensure email is provided.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _authService.verifyEmail(_email, _codeController.text);

    setState(() {
      _isLoading = false;
    });

    if (response['success']) {
      _showSnackBar(response['message']);
      Navigator.of(context).pushReplacementNamed('/profile_picture_upload');
    } else {
      _showSnackBar(response['message'], isError: true);
    }
  }

  Future<void> _resendOtp() async {
    if (_email.isEmpty) {
      _showSnackBar('Email not provided to resend OTP.', isError: true);
      return;
    }
    // TODO: Implement resend OTP API call in AuthService
    _showSnackBar('Resending OTP (not implemented in backend yet)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the OTP code sent to your email.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter OTP Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resendOtp,
                child: const Text('Resend OTP'),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              text: 'Verify & Continue',
              onPressed: _verifyEmail,
            ),
          ],
        ),
      ),
    );
  }
}