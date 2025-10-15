import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider with ChangeNotifier {
  String? _role;
  String? get role => _role;

  String? _fullName; // ✅ ADDED: To store the user's name
  String? get fullName => _fullName; // ✅ ADDED: A getter for the name

  late final StreamSubscription<AuthState> _authSubscription;

  ProfileProvider() {
    _loadProfile();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        _loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('role, full_name') // ✅ MODIFIED: Now fetches 'full_name'
            .eq('id', user.id)
            .single();
        _role = data['role'];
        _fullName = data['full_name']; // ✅ MODIFIED: Now stores 'full_name'
      } catch (e) {
        _role = 'user';
        _fullName = 'User'; // Default name on error
        print('Error loading profile: $e'); // Added for debugging
      }
    } else {
      _role = null;
      _fullName = null; // Clear name on logout
    }
    notifyListeners();
  }
}