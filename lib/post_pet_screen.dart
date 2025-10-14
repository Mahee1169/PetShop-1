// Remove dart:io completely from imports for web compatibility
// import 'dart:io'; // REMOVE THIS LINE
import 'dart:typed_data'; // We'll use Uint8List for web image data

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

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
  bool _isLoading = false;

  // ✅ FIX: Use XFile to store the picked file reference for both platforms
  XFile? _selectedXFile;
  // ✅ FIX: Use Uint8List to store the actual image bytes for display on web
  Uint8List? _imageBytesForWebDisplay;

  @override
  void dispose() {
    _petNameController.dispose();
    _priceController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _selectedXFile = pickedFile;
        if (kIsWeb) {
          // If on web, load bytes directly for preview
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _imageBytesForWebDisplay = bytes;
            });
          });
        }
      });
    }
  }

  Future<void> _postPet() async {
    if (_selectedXFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image for your pet!'), backgroundColor: Colors.red),
      );
      return;
    }
    // ... other validation ...
    setState(() { _isLoading = true; });

    final petName = _petNameController.text.trim();
    final priceText = _priceController.text.trim();
    final location = _locationController.text.trim();
    final userId = Supabase.instance.client.auth.currentUser?.id;

    try {
      final fileExtension = p.extension(_selectedXFile!.name);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      
      // ✅ FIX: Always read bytes for upload, works for both mobile and web
      final Uint8List imageBytes = await _selectedXFile!.readAsBytes();

      await Supabase.instance.client.storage
          .from('pet_images')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: FileOptions(contentType: _selectedXFile!.mimeType),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('pet_images')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('pets').insert({
        'name': petName,
        'price': double.tryParse(priceText) ?? 0,
        'location': location,
        'imagePath': imageUrl,
        'category': _selectedCategory,
        'user_id': userId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet posted successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting pet: ${error.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Your Pet'),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ Color(0xFFD1E8D6), Color(0xFFE4E6F1) ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 2)
                  ),
                  // ✅ FIX: Corrected image preview logic for both web and mobile
                  child: _selectedXFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: kIsWeb && _imageBytesForWebDisplay != null
                              ? Image.memory(_imageBytesForWebDisplay!, fit: BoxFit.cover, width: double.infinity)
                              : Image.network(_selectedXFile!.path, fit: BoxFit.cover, width: double.infinity), // For mobile and if web bytes aren't ready
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap to upload an image'),
                          ],
                        ),
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
              
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _postPet,
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

  Widget _buildTextField(TextEditingController controller, String hintText, {int maxLines = 1, TextInputType? keyboardType}) { return TextField( controller: controller, maxLines: maxLines, keyboardType: keyboardType, decoration: InputDecoration( filled: true, fillColor: Colors.white.withOpacity(0.8), hintText: hintText, border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none, ), hintStyle: GoogleFonts.publicSans(color: Colors.black54), ), ); }
  Widget _buildCategoryDropdown() { return Container( padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration( color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12), ), child: DropdownButtonHideUnderline( child: DropdownButton<String>( value: _selectedCategory, isExpanded: true, dropdownColor: Colors.white, items: <String>['Dogs', 'Cats', 'Birds', 'Reptiles', 'Small Pets'] .map<DropdownMenuItem<String>>((String value) { return DropdownMenuItem<String>( value: value, child: Text(value), ); }).toList(), onChanged: (String? newValue) { setState(() { _selectedCategory = newValue!; }); }, ), ), ); }
}