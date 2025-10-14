import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider with ChangeNotifier {
  String? _role;
  String? get role => _role;

  late final StreamSubscription<AuthState> _authSubscription;

  ProfileProvider() {
    // Get the initial user state
    _loadProfile();

    // ✅ Listen for changes in authentication (login, logout)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      // When the user signs in or signs out, reload their profile
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        _loadProfile();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the listener when the provider is removed
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();
        _role = data['role'];
      } catch (e) {
        // If profile doesn't exist or there's an error, default to 'user'
        _role = 'user';
      }
    } else {
      // If no user is logged in, the role is null
      _role = null;
    }
    // Notify the app that the role has been updated
    notifyListeners();
  }
}