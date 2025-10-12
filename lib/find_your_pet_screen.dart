import 'package:flutter/material.dart';
import 'login_screen.dart';

class FindYourPetScreen extends StatelessWidget {
  const FindYourPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body container now handles the background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFC7A7),
              Color(0xFFFFD4B8),
              Color(0xFFFEE2AD),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          // Using Center and Column to perfectly center the content
          child: Center(
            child: SingleChildScrollView( // Prevents overflow on small screens
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/paw.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Find Your Pet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A1F00),
                    ),
                  ),
                  const SizedBox(height: 100),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjusted padding
                    child: Text(
                      'Make your bonding relationship\nbetween human & pets',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A1F00),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      // This navigation works, but using named routes is better for consistency.
                      // Navigator.pushNamed(context, '/login');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Container(
                      width: 160,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF9E6B)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(2, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_right_alt, color: Colors.white, size: 26),
                          SizedBox(width: 4),
                          Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}