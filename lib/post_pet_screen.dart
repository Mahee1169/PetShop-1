import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostPetScreen extends StatefulWidget {
  const PostPetScreen({super.key});

  @override
  State<PostPetScreen> createState() => _PostPetScreenState();
}

class _PostPetScreenState extends State<PostPetScreen> {
  final _petNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Dogs';

  @override
  void dispose() {
    _petNameController.dispose();
    _priceController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Your Pet'),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
        automaticallyImplyLeading: false, // Prevents default back button
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Upload Section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Upload the image of your pet',
                      style: GoogleFonts.publicSans(color: Colors.black54, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement image upload functionality
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text('Upload', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5841),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_petNameController, 'Pet Name'),
              const SizedBox(height: 16),
              _buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_ageController, 'Age', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_locationController, 'Location'),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description (optional)', maxLines: 4),
              const SizedBox(height: 24),
              
              // Post Button with Corrected Navigation
              ElevatedButton(
                onPressed: _postPet, // Call the post pet function
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('Post', style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
              // Already on Sell, do nothing
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

  // Logic to post a pet, separated for cleanliness
  Future<void> _postPet() async {
    final petName = _petNameController.text.trim();
    final priceText = _priceController.text.trim();
    final location = _locationController.text.trim();

    // Basic validation
    if (petName.isEmpty || priceText.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields!'), backgroundColor: Colors.red),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number for the price!'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // Call Supabase to insert the new pet
      await Supabase.instance.client.from('pets').insert({
        'name': petName,
        'price': price,
        'location': location,
        'imagePath': 'assets/images/Golden Retriever.png', // Placeholder image for now
        'category': _selectedCategory,
      });

      // THE FIX: Check if the screen is still mounted before showing UI
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet posted successfully!'), backgroundColor: Colors.green),
      );

      // ✅ CORRECT NAVIGATION: Go to home and clear history
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting pet: ${error.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  // Helper widget for TextFields
  Widget _buildTextField(TextEditingController controller, String hintText, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.publicSans(color: Colors.black54),
      ),
    );
  }

  // Helper widget for the Category dropdown
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: Colors.white,
          items: <String>['Dogs', 'Cats', 'Birds', 'Reptiles', 'Small Pets']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }
}