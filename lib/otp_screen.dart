import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() { _isLoading = true; });

    // Get the email that was passed from the SignUpScreen
    final email = ModalRoute.of(context)!.settings.arguments as String?;
    final otp = _otpController.text.trim();

    if (email == null || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP or Email'), backgroundColor: Colors.red));
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // ✅ This is the key function to verify the OTP
      final AuthResponse res = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup, // Specify that this is a signup OTP
        token: otp,
        email: email,
      );

      // If verification is successful, res.user will not be null, and the user is logged in!
      if (mounted && res.user != null) {
        // Go to home screen and clear all previous routes
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on AuthException catch (error) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message), backgroundColor: Colors.red));
      }
    } catch (error) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: Colors.red));
      }
    }

    if(mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // A simple UI for OTP entry
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: '6-Digit OTP Code'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOtp,
                      child: const Text('Verify'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}