import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase
import 'pet_details_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _selectedCategory = 'Dogs';
  final _searchController = TextEditingController();

  // 2. This now holds the database query, not the data itself.
  // It's a "Future", meaning the data will arrive in the future.
  final _petsStream = Supabase.instance.client.from('pets').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Pets'),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Color(0xFFD1E8D6),
              Color(0xFFE4E6F1),
            ],
            stops: const [0.4764, 0.8868],
            transform: GradientRotation(171.18 * 3.1416 / 180),
          ),
        ),
        child: Column(
          children: [
            // Search Bar (no changes needed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search for pets...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // Category Pills (no changes needed)
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

            // 3. This section is now wrapped in a FutureBuilder
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _petsStream, // It waits for the database query to complete
                builder: (context, snapshot) {
                  // While waiting, show a loading circle
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // If there was an error, show it
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Once data arrives, store it
                  final pets = snapshot.data!;

                  // Filter the data based on the selected category
                  final filteredPets = pets.where((pet) => pet['category'] == _selectedCategory).toList();

                  // If no pets are found in the category, show a message
                  if (filteredPets.isEmpty) {
                    return Center(child: Text('No pets found in the $_selectedCategory category!'));
                  }

                  // Build the grid using the live data from the database
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredPets.length,
                    itemBuilder: (context, index) {
                      final pet = filteredPets[index];

                      // 4. Format the numeric price from DB into a display string
                      final price = pet['price'];
                      final formattedPrice = '\$${price.toStringAsFixed(0)}';

                      return _buildPetCard(
                        pet['name'],
                        formattedPrice, // Use the formatted price string
                        pet['location'],
                        pet['imagePath'],
                      );
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // No changes needed for the helper widgets below
  Widget _buildCategoryPill(String text) {
    final isSelected = _selectedCategory == text;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          text,
          style: TextStyle(
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

  Widget _buildPetCard(String name, String price, String location, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailsScreen(
              name: name,
              price: price,
              location: location,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600,),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12,),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}