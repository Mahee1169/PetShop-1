import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pet_details_screen.dart';
import 'profile_provider.dart'; // Make sure this path is correct

class HomeScreen extends StatefulWidget { // ✅ CORRECTED CLASS NAME
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // ✅ CORRECTED STATE NAME
}

class _HomeScreenState extends State<HomeScreen> { // ✅ CORRECTED STATE NAME
  final _petsStream = Supabase.instance.client
      .from('pets')
      .stream(primaryKey: ['id'])
      .eq('status', 'approved')
      .order('created_at', ascending: false);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userName = profileProvider.fullName; // For the personalized welcome message
    final isAdmin = profileProvider.role == 'admin'; // For potential admin features

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD1E8D6), Color(0xFFE4E6F1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              // Personalized Welcome Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Hello, ${userName ?? 'Guest'}!',
                  style: GoogleFonts.workSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildMainTitle(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _petsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No pets found yet.',
                          style: GoogleFonts.workSans(color: Colors.grey[600]),
                        ),
                      );
                    }

                    final pets = snapshot.data!;
                    return GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return _buildPetCard(pet, isAdmin);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFFF9E6B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on Home
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

  Widget _buildPetCard(Map<String, dynamic> pet, bool isAdmin) {
    final int petId = pet['id'];
    final String name = pet['name'] ?? 'No Name';
    final String location = pet['location'] ?? 'No Location';
    final String imagePath = pet['imagePath'] ?? '';
    final price = pet['price'] ?? 0;
    final formattedPrice = '৳${price.toStringAsFixed(0)}';
    final String description = pet['description'] ?? 'No description provided.';
    final String userId = pet['user_id'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailsScreen(
              petId: petId,
              name: name,
              price: formattedPrice,
              location: location,
              imagePath: imagePath,
              description: description,
              userId: userId,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(formattedPrice, style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)]),
            ),
            child: Center(
              child: Image.asset('assets/images/paw.png', width: 28, height: 28, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PetMarket',
            style: GoogleFonts.workSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF2D3436)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Find Your Perfect Pet',
        style: GoogleFonts.workSans(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF2D3436)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search for pets...',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }
}