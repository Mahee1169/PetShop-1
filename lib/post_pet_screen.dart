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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD1E8D6), // Light mint green
              Color(0xFFE4E6F1), // Light blue-grey
            ],
            stops: [0.4764, 0.8868],
            transform: GradientRotation(171.18 * 3.1416 / 180),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Post Your Pet',
                      style: GoogleFonts.publicSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Upload the image of your pet',
                              style: GoogleFonts.publicSans(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Implement image upload
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5841),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Upload',
                                style: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.w600,
                                ),
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
                      _buildTextField(_descriptionController, 'Description', maxLines: 4),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          final petName = _petNameController.text;
                          final priceText = _priceController.text;
                          final location = _locationController.text;

                          if (petName.isEmpty || priceText.isEmpty || location.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all required fields!'), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          final price = double.tryParse(priceText);
                          if (price == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid price!'), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          try {
                            await Supabase.instance.client.from('pets').insert({
                              'name': petName,
                              'price': price,
                              'location': location,
                              'imagePath': 'assets/images/Golden Retriever.png',
                              'category': _selectedCategory,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pet posted successfully!'), backgroundColor: Colors.green),
                            );
                            Navigator.pop(context);
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error posting pet: $error'), backgroundColor: Colors.red),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Post',
                          style: GoogleFonts.publicSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ✅ FIX: Added the required 'items' property
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

  Widget _buildTextField(TextEditingController controller, String hintText, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFFE5E5),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.publicSans(
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: const Color(0xFFFFF0F0),
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