import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  late Future<List<Map<String, dynamic>>> _pendingPetsFuture;

  @override
  void initState() {
    super.initState();
    _pendingPetsFuture = _fetchPendingPets();
  }

  Future<List<Map<String, dynamic>>> _fetchPendingPets() async {
    return await Supabase.instance.client
        .from('pets')
        .select()
        .eq('status', 'pending');
  }

  Future<void> _updatePetStatus(int petId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('pets')
          .update({'status': newStatus})
          .eq('id', petId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pet has been ${newStatus}d!'), backgroundColor: Colors.green),
        );
      
        setState(() {
          _pendingPetsFuture = _fetchPendingPets();
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Approvals', style: GoogleFonts.workSans())),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pendingPetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading pending pets.'));
          }
          final pendingPets = snapshot.data!;
          if (pendingPets.isEmpty) {
            return const Center(child: Text('No pets are currently pending approval.'));
          }
          return ListView.builder(
            itemCount: pendingPets.length,
            itemBuilder: (context, index) {
              final pet = pendingPets[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Image.network(pet['imagePath'], width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(pet['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(pet['location']),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _updatePetStatus(pet['id'], 'rejected'),
                            child: const Text('Reject', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _updatePetStatus(pet['id'], 'approved'),
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}