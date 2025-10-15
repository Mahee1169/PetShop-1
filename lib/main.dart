import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Providers
import 'cart_provider.dart';
import 'profile_provider.dart';

// Screens - Ensure these class names and file names match
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'payment_screen.dart';
import 'otp_screen.dart';
import 'my_pets_screen.dart';
import 'my_orders_screen.dart';
import 'admin_approval_screen.dart';
import 'admin_orders_screen.dart';
import 'find_your_pet_screen.dart';
import 'password_reset_success_screen.dart';
import 'home_screen.dart'; // This file should contain `class HomeScreen`
import 'login_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'browse_screen.dart'; // This file should contain `class BrowseScreen`
import 'post_pet_screen.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import 'new_password_screen.dart';

// ✅ Removed unnecessary exports. Exports are usually for library packages.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://irnsznncfwygxfnwwubh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlybnN6bm5jZnd5Z3hmbnd3dWJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxNTMyMDksImV4cCI6MjA3NTcyOTIwOX0.gv7a_Xbml1u44ov3ihFbbdymhHjaObvbcONY94OpgCg',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        _navigatorKey.currentState?.pushNamed('/newpassword');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
          '/my-pets': (context) => const MyPetsScreen(),
          '/my-orders': (context) => const MyOrdersScreen(),
          '/admin-approval': (context) => const AdminApprovalScreen(),
          '/admin-orders': (context) => const AdminOrdersScreen(),
        },
      ),
    );
  }
}