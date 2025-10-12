import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ Supabase import added
import 'cart_provider.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'payment_screen.dart';

// Your other screen imports remain the same
import 'find_your_pet_screen.dart';
import 'password_reset_success_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'browse_screen.dart';
import 'post_pet_screen.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import 'new_password_screen.dart';

// Your exports remain the same
export 'find_your_pet_screen.dart';
export 'login_screen.dart';
export 'signup_screen.dart';
export 'forgot_password_screen.dart';
export 'new_password_screen.dart';
export 'password_reset_success_screen.dart';
export 'browse_screen.dart';
export 'post_pet_screen.dart';
export 'profile_screen.dart';
export 'edit_profile_screen.dart';

// ✅ Updated main function to initialize Supabase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://irnsznncfwygxfnwwubh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlybnN6bm5jZnd5Z3hmbnd3dWJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxNTMyMDksImV4cCI6MjA3NTcyOTIwOX0.gv7a_Xbml1u44ov3ihFbbdymhHjaObvbcONY94OpgCg',
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pet Market',
        theme: ThemeData(
          textTheme: GoogleFonts.workSansTextTheme(),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const FindYourPetScreen(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/newpassword': (context) => const NewPasswordScreen(),
          '/password-reset-success':
              (context) => const PasswordResetSuccessScreen(),
          '/browse': (context) => const BrowseScreen(),
          '/post-pet': (context) => const PostPetScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/payment': (context) => const PaymentScreen(),
        },
      ),
    );
  }
}