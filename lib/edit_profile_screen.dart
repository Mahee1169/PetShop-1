import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = true; 
  XFile? _selectedImageFile;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', userId)
          .single();
      if (mounted) {
        _nameController.text = data['full_name'] ?? '';
        _currentAvatarUrl = data['avatar_url'];
      }
    } catch (error) {
      // Handle error
    } finally {
      if(mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = pickedFile;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() { _isLoading = true; });
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    String? imageUrl = _currentAvatarUrl;

    try {
      if (_selectedImageFile != null) {
        final imageBytes = await _selectedImageFile!.readAsBytes();
        final fileExt = p.extension(_selectedImageFile!.name);
        final fileName = 'avatar$fileExt';
        final filePath = '${user.id}/$fileName';

        await Supabase.instance.client.storage.from('avatars').uploadBinary(
              filePath,
              imageBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );

        imageUrl = '${Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath)}?t=${DateTime.now().millisecondsSinceEpoch}';
      }

      await Supabase.instance.client.from('profiles').update({
        'full_name': name,
        'avatar_url': imageUrl,
      }).eq('id', user.id);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': name}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${error.toString()}'), backgroundColor: Colors.red),
        );
      }
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
        title: Text('Edit Profile', style: GoogleFonts.workSans()),
        backgroundColor: const Color(0xFFD1E8D6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: _selectedImageFile != null
                                  ? (kIsWeb
                                      ? NetworkImage(_selectedImageFile!.path)
                                      : FileImage(File(_selectedImageFile!.path))) as ImageProvider
                                  : (_currentAvatarUrl != null
                                      ? NetworkImage(_currentAvatarUrl!)
                                      : null),
                              child: (_selectedImageFile == null && _currentAvatarUrl == null)
                                  ? const Icon(Icons.person, size: 80, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFF9747FF),
                                child: const Icon(Icons.edit, color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Full Name',
                      style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9747FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.publicSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}