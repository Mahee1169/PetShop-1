import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    if (mounted) {
      setState(() { _isLoading = true; });
    }
    
    try {
      // ✅ FIX: Check if the user exists before getting the ID
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        // If user is logged out, don't try to fetch a profile
        setState(() { _isLoading = false; });
        return;
      }
      
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load profile. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (error) {
      // Handle error if needed
    }
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isAdmin = profileProvider.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.workSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD1E8D6),
              Color(0xFFE4E6F1),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _getProfile,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 30),
                        _buildProfileOption(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.pushNamed(context, '/edit-profile').then((_) => _getProfile());
                          },
                        ),
                        _buildProfileOption(
                          icon: Icons.pets_outlined,
                          title: 'My Posted Pets',
                          onTap: () {
                            Navigator.pushNamed(context, '/my-pets');
                          },
                        ),
                        _buildProfileOption(
                          icon: Icons.receipt_long,
                          title: 'My Orders',
                          onTap: () {
                            Navigator.pushNamed(context, '/my-orders');
                          },
                        ),
                        if (isAdmin)
                          _buildProfileOption(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Pending Approvals',
                            onTap: () {
                              Navigator.pushNamed(context, '/admin-approval');
                            },
                          ),
                        if (isAdmin)
                          _buildProfileOption(
                            icon: Icons.receipt_long_outlined,
                            title: 'Manage Orders',
                            onTap: () {
                              Navigator.pushNamed(context, '/admin-orders');
                            },
                          ),
                        _buildProfileOption(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: _signOut,
                          isLogout: true,
                        ),
                      ],
                    ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFFFF9E6B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/browse');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/post-pet');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final avatarUrl = _profileData?['avatar_url'];
    final fullName = _profileData?['full_name'] ?? 'No Name';
    // ✅ FIX: Use the null-aware operator '?.' to safely access the email
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'No Email';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: GoogleFonts.workSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: GoogleFonts.workSans(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final color = isLogout ? Colors.redAccent : const Color(0xFF2D3436);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              if (!isLogout)
                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}