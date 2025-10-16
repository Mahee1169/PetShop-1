import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_provider.dart';

class PetDetailsScreen extends StatefulWidget {
  final int petId;
  final String name;
  final String price;
  final String location;
  final String imagePath;
  final String description;
  final String userId; 

  const PetDetailsScreen({
    super.key,
    required this.petId,
    required this.name,
    required this.price,
    required this.location,
    required this.imagePath,
    required this.description,
    required this.userId,
  });

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  String _sellerName = 'Loading...'; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSellerName(); 
  }
  Future<void> _fetchSellerName() async {
    if (widget.userId.isEmpty) {
      setState(() {
        _sellerName = 'Unknown Seller';
        _isLoading = false;
      });
      return;
    }
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('full_name') 
          .eq('id', widget.userId)
          .single();
      if (mounted) {
        setState(() {
          _sellerName = data['full_name'] ?? 'Unknown Seller';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sellerName = 'Unknown Seller';
          _isLoading = false;
        });
      }
      print('Error fetching seller name: $e'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Details',
                      style: GoogleFonts.workSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.error, color: Colors.red, size: 50));
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.name, style: GoogleFonts.workSans(fontSize: 24, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(widget.location, style: GoogleFonts.workSans(fontSize: 16, color: Colors.grey[600])),
                                  ],
                                ),
                                Text(widget.price, style: GoogleFonts.workSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2ECC71))),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text('Description', style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(
                              widget.description,
                              style: GoogleFonts.workSans(fontSize: 16, color: Colors.grey[600], height: 1.5),
                            ),
                            const SizedBox(height: 24),
                            Text('Seller Information', style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(radius: 24, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                              title: Text(
                                _sellerName, 
                                style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('Verified Seller', style: GoogleFonts.workSans(color: Colors.grey)),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Provider.of<CartProvider>(context, listen: false).addItem(
                                    widget.petId,
                                    widget.name,
                                    widget.price,
                                    widget.imagePath,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${widget.name} added to your cart!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart_outlined),
                                label: Text('Add to Cart', style: GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9E6B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
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