import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

// Your other imports for signup_screen, forgot_password_screen are fine

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() { _isLoading = true; });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red));
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // ✅ This is the key function to sign in a user
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message), backgroundColor: Colors.red));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: Colors.red));
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // I am using your existing beautiful UI and just changing the button's action
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFC7A7), Color(0xFFFFD4B8), Color(0xFFFEE2AD)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/paw.png', width: 100, height: 100),
                        const SizedBox(height: 40),
                        _buildTextField(controller: _emailController, hintText: 'Enter phone number or gmail', obscureText: false),
                        const SizedBox(height: 20),
                        _buildTextField(controller: _passwordController, hintText: 'Enter Password', obscureText: true),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () { Navigator.pushNamed(context, '/forgot-password'); },
                            child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF7A1F00), fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ✅ Sign in Button now calls _signIn
                        _isLoading
                          ? const CircularProgressIndicator()
                          : _buildMainButton(text: 'Sign in', onTap: _signIn),

                        const SizedBox(height: 30),
                        const Text("Don't have an account?", style: TextStyle(color: Color(0xFF7A1F00), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        _buildOutlinedButton(text: 'Sign up', onTap: () { Navigator.pushNamed(context, '/signup'); }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  // Your helper methods _buildTextField, _buildMainButton, _buildOutlinedButton remain exactly the same
  // ... (paste your helper methods here) ...
   Widget _buildTextField({ required String hintText, required bool obscureText, required TextEditingController controller, }) { return Container( decoration: BoxDecoration( gradient: const LinearGradient( colors: [Color(0xFFFFBE98), Color(0xFFFFD4B8)], begin: Alignment.centerLeft, end: Alignment.centerRight, ), borderRadius: BorderRadius.circular(20), boxShadow: [ BoxShadow( color: const Color(0xFF7A1F00).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4), ), ], ), child: TextField( controller: controller, obscureText: obscureText, decoration: InputDecoration( hintText: hintText, hintStyle: const TextStyle( color: Color(0xFF7A1F00), fontWeight: FontWeight.w600, fontSize: 16, ), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), ), ), ); }
   Widget _buildMainButton({required String text, required VoidCallback onTap}) { return GestureDetector( onTap: onTap, child: Container( width: double.infinity, height: 50, decoration: BoxDecoration( color: const Color(0xFFFF9E6B), borderRadius: BorderRadius.circular(25), boxShadow: const [ BoxShadow( color: Colors.black26, blurRadius: 5, offset: Offset(2, 3), ), ], ), child: Center( child: Text( text, style: const TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, ), ), ), ), ); }
   Widget _buildOutlinedButton( {required String text, required VoidCallback onTap}) { return GestureDetector( onTap: onTap, child: Container( width: double.infinity, height: 50, decoration: BoxDecoration( borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFF7A1F00), width: 2), color: Colors.transparent, ), child: Center( child: Text( text, style: const TextStyle( color: Color(0xFF7A1F00), fontWeight: FontWeight.bold, fontSize: 16, ), ), ), ), ); }
}