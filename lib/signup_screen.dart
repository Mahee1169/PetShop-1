import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'utils/validation_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _validateInputs(BuildContext context) {
    final input = _emailPhoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (input.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return false;
    }

    // Validate email/phone
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

    // Check if passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
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
              children: [
                const SizedBox(height: 20),
                
                // 🐾 Paw Logo with gradient
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF6B9D),
                        Color(0xFFFF8E53),
                        Color(0xFFFFA726),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(70),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8E53).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(67),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/paw.png',
                        width: 85,
                        height: 85,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),

                // 📱 Phone/Email Field
                _buildTextField(
                  hintText: 'Enter phone number or gmail',
                ),
                const SizedBox(height: 20),

                // 🔒 Password Field
                _buildTextField(
                  hintText: 'Enter Password',
                ),
                const SizedBox(height: 20),

                // 🔒 Confirm Password Field
                _buildTextField(
                  hintText: 'Confirm Password',
                ),
                
                const SizedBox(height: 120),

                // ✅ Next Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      if (_validateInputs(context)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OtpScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF00C853)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📋 Reusable Text Field
  Widget _buildTextField({required String hintText}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        obscureText: hintText.toLowerCase().contains('password'),
        style: const TextStyle(
          color: Color(0xFF7A1F00),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF7A1F00).withOpacity(0.7),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            hintText.toLowerCase().contains('password') 
                ? Icons.lock_outline
                : Icons.email_outlined,
            color: const Color(0xFF7A1F00),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}