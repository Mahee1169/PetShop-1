import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The main container for the background gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD1E8D6), // Light mint green
              Color(0xFFE4E6F1), // Light blue-grey
            ],
          ),
        ),
        // SafeArea keeps our UI from being blocked by the phone's notch or system bars
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: The header with the logo and app name
              _buildHeader(),

              // We add space to give the UI breathing room
              const SizedBox(height: 30),

              // Section 2: The main title of the screen
              _buildMainTitle(),

              // More space before the search bar
              const SizedBox(height: 24),

              // Section 3: The search bar
              _buildSearchBar(),

              // Section 4: This is where your pet listings will go.
              // We use Expanded so it takes up all the remaining space.
              Expanded(
                child: Center(
                  child: Text(
                    'Pet listings will appear here...',
                    style: GoogleFonts.workSans(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // The bottom navigation bar, with "Home" selected
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 0 is the index for the 'Home' tab
        selectedItemColor: const Color(0xFFFF9E6B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // This handles navigation when a tab is tapped
          switch (index) {
            case 0:
              // Already on Home, do nothing
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/browse');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/post-pet');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // --- Helper Methods to Keep the Code Clean ---

  // This widget builds the header with the logo and "PetMarket" text
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0), // Added more top padding
      child: Row(
        children: [
          // ✅ CONSISTENT LOGO: The white paw inside the gradient circle
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/paw.png',
                width: 28,
                height: 28,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PetMarket',
            style: GoogleFonts.workSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }

  // This widget builds the main title "Find Your Perfect Pet"
  Widget _buildMainTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Find Your Perfect Pet',
        style: GoogleFonts.workSans(
          fontSize: 32,
          fontWeight: FontWeight.w900, // Make it extra bold
          color: const Color(0xFF2D3436),
        ),
      ),
    );
  }

  // This widget builds the modern search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      // The Container provides the white background and shadow
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18), // Softer corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // The TextField is where the user will type
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search for pets...',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            // No border for a clean, modern look
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}