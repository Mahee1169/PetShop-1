import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'utils/validation_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _validateInputs(BuildContext context) {
    final input = _emailController.text.trim();
    final password = _passwordController.text;

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return false;
    }

    // Check if input is email or phone
    bool isValid;
    String errorMessage;
    if (ValidationUtils.isEmail(input)) {
      isValid = ValidationUtils.isValidEmail(input);
      errorMessage = 'Please enter a valid email address';
    } else {
      isValid = ValidationUtils.isValidPhone(input);
      errorMessage = 'Please enter a valid phone number';
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return false;
    }

    // Validate password
    String passwordError = ValidationUtils.getPasswordValidationMessage(password);
    if (passwordError.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 32,
              right: 32,
              top: 40,
              bottom: MediaQuery.of(context).padding.bottom + 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🐾 Paw Logo
                Image.asset(
                  'assets/images/paw.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 40),

                // 📱 Phone/Email Field
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Enter phone number or gmail',
                  obscureText: false,
                ),
                const SizedBox(height: 20),

                // 🔒 Password Field
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Enter Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF7A1F00),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 🔘 Sign in Button
                _buildMainButton(
                  text: 'Sign in',
                  onTap: () {
                    // You can add validation here before navigation
                    if (_validateInputs(context)) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false, // This clears the navigation stack
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),

                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Color(0xFF7A1F00),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // 🧾 Sign Up Button
                _buildOutlinedButton(
                  text: 'Sign up',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 🔵 Continue with Google Button
                _buildGoogleButton(
                  text: 'Continue with Google',
                  onTap: () {
                    // TODO: Add Google Sign-In functionality later
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📋 Reusable Text Field
  Widget _buildTextField({
    required String hintText,
    required bool obscureText,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFBE98), Color(0xFFFFD4B8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A1F00).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF7A1F00),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // 🟠 Main Button (Sign in)
  Widget _buildMainButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFF9E6B),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // 🟤 Outlined Button (Sign up)
  Widget _buildOutlinedButton(
      {required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF7A1F00), width: 2),
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF7A1F00),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // 🔴 Google Button
  Widget _buildGoogleButton(
      {required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF9E6B), Color(0xFFFFA726)],
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/google.png',
              height: 22,
              width: 22,
            ),
          ],
        ),
      ),
    );
  }
}