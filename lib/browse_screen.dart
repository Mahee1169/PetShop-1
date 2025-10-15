import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pet_details_screen.dart';
import 'profile_provider.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _selectedCategory = 'Dogs';
  final _searchController = TextEditingController();

  // ✅ Corrected Supabase stream query
  // We use .select() before .asStream()
  final _petsStream = Supabase.instance.client
      .from('pets')
      .select('*, profiles(full_name)') // include seller name
      .order('created_at', ascending: false)
      .asStream(); // convert the result into a stream

  Future<void> _deletePet(int petId) async {
    try {
      await Supabase.instance.client.from('pets').delete().eq('id', petId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet listing deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete pet: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(int petId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete This Listing?'),
        content: const Text(
            'Are you sure you want to permanently delete this pet listing? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deletePet(petId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isAdmin = profileProvider.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Pets', style: GoogleFonts.workSans()),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Open Cart',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for pets...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryPill('Dogs'),
                  _buildCategoryPill('Cats'),
                  _buildCategoryPill('Birds'),
                  _buildCategoryPill('Reptiles'),
                  _buildCategoryPill('Small Pets'),
                ],
              ),
            ),
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
                      child: Text('No pets found.',
                          style: GoogleFonts.workSans()),
                    );
                  }

                  final allPets = snapshot.data!;
                  final petsToShow = isAdmin
                      ? allPets
                      : allPets
                          .where((p) => p['status'] == 'approved')
                          .toList();

                  final filteredPets = petsToShow
                      .where((pet) => pet['category'] == _selectedCategory)
                      .toList();

                  if (filteredPets.isEmpty) {
                    return Center(
                      child: Text(
                        'No pets found in the $_selectedCategory category!',
                        style: GoogleFonts.workSans(),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredPets.length,
                    itemBuilder: (context, index) {
                      final pet = filteredPets[index];
                      return _buildPetCard(pet, isAdmin);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFFFF9E6B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
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
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Sell'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String text) {
    final isSelected = _selectedCategory == text;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          text,
          style: GoogleFonts.workSans(
            color: isSelected ? Colors.white : const Color(0xFF7A1F00),
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _selectedCategory = text;
            });
          }
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFFF9E6B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFF9E6B)),
        ),
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
    final String sellerName = (pet['profiles'] != null &&
            pet['profiles']['full_name'] != null)
        ? pet['profiles']['full_name']
        : 'Unknown Seller';
    final String status = pet['status'] ?? 'unknown';

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
              sellerName: sellerName,
              userId: userId,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Stack(
          children: [
            Column(
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
                      return const Center(
                          child: Icon(Icons.error, color: Colors.red));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.workSans(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(formattedPrice,
                          style: GoogleFonts.workSans(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(location,
                          style: GoogleFonts.workSans(
                              color: Colors.grey[600], fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            if (isAdmin)
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.85),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.redAccent, size: 22),
                    onPressed: () => _showDeleteConfirmation(petId),
                  ),
                ),
              ),
            if (isAdmin && status != 'approved')
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: status == 'pending' ? Colors.orange : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
