import 'package:flutter/material.dart';

// Assuming you have a login screen to return to, 
// using FindYourPetScreen as a simple placeholder for navigation destination.
import 'find_your_pet_screen.dart'; 

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  static const Color darkBrown = Color(0xFF7A1F00);
  static const Color successGreen = Color(0xFF00C853);
  static const Color primaryRed = Color(0xFFFF6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFC7A7),
              Color(0xFFFEE2AD),
            ],
            stops: [0.47, 0.88],
            transform: GradientRotation(171.18 * 3.1416 / 180),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Success Checkmark Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: successGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: successGreen.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 40),

                // Success Message
                const Text(
                  'Password Changed!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your password has been successfully updated. Please log in with your new credentials.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const Spacer(flex: 3),

                // Go to Login Button
                GestureDetector(
                  onTap: () {
                    // Navigate to main app (or login screen) and clear the stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FindYourPetScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [primaryRed, darkBrown],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'GO TO LOGIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
