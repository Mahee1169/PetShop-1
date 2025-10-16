import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});
  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}
class _MyPetsScreenState extends State<MyPetsScreen> {
  late final Future<List<Map<String, dynamic>>> _myPetsFuture;
  @override
  void initState() {
    super.initState();
    _myPetsFuture = _fetchMyPets();
  }
  Future<List<Map<String, dynamic>>> _fetchMyPets() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('pets')
          .select()
          .eq('user_id', userId) 
          .order('created_at', ascending: false);
      return data;
    } catch (error) {
      throw Exception('Could not load your pets. Please try again.');
    }
  }

  Future<void> _deletePet(int petId) async {
    try {
      await Supabase.instance.client.from('pets').delete().eq('id', petId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet listing deleted successfully'), backgroundColor: Colors.green),
        );
        setState(() {
          _myPetsFuture = _fetchMyPets();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete pet listing'), backgroundColor: Colors.red),
        );
      }
    }
  }
  void _showDeleteConfirmation(int petId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Pet Listing?'),
          content: const Text('Are you sure you want to permanently delete this listing? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                _deletePet(petId);    
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Posted Pets', style: GoogleFonts.workSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
      ),
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _myPetsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final myPets = snapshot.data!;
            if (myPets.isEmpty) {
              return Center(
                child: Text(
                  'You have not posted any pets yet.',
                  style: GoogleFonts.workSans(fontSize: 18, color: Colors.grey[700]),
                ),
              );
            }
            return ListView.builder(
              itemCount: myPets.length,
              itemBuilder: (context, index) {
                final pet = myPets[index];
                final price = pet['price'] ?? 0;
                final formattedPrice = '\$${price.toStringAsFixed(0)}';
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        pet['imagePath'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.pets, color: Colors.grey, size: 40),
                      ),
                    ),
                    title: Text(
                      pet['name'] ?? 'No Name',
                      style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Price: $formattedPrice', style: GoogleFonts.workSans()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Delete Listing',
                      onPressed: () {
                        _showDeleteConfirmation(pet['id']);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}