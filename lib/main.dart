import 'dart:async'; // Import for StreamSubscription
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_provider.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'payment_screen.dart';
import 'otp_screen.dart';

// Your other screen imports
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

// Your exports
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://irnsznncfwygxfnwwubh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlybnN6bm5jZnd5Z3hmbnd3dWJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk0NzE5MTcsImV4cCI6MjA0NTA0NzkxN30.C-0vR_Vz11WpLgM4Y-eLqM7FjL5C4mD3B73k1p9y_y0',
  );
  runApp(const MyApp());
}

// ✅ Changed to a StatefulWidget to listen for auth changes
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // A key to control navigation from outside the widget tree
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel(); // Clean up the listener
    super.dispose();
  }

  void _setupAuthListener() {
    // This listens for when a user clicks the password reset link
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // When the link is clicked, this event fires.
        // We use the navigatorKey to safely navigate to the new password screen.
        _navigatorKey.currentState?.pushNamed('/newpassword');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        navigatorKey: _navigatorKey, // ✅ Assign the navigator key
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
          '/password-reset-success': (context) => const PasswordResetSuccessScreen(),
          '/browse': (context) => const BrowseScreen(),
          '/post-pet': (context) => const PostPetScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/otp': (context) => const OtpScreen(),
        },
      ),
    );
  }
}

