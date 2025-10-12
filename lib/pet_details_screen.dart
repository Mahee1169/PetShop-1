import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import the provider package
import 'cart_provider.dart';           // 2. Import your CartProvider

class PetDetailsScreen extends StatelessWidget {
  final String name;
  final String price;
  final String location;
  final String imagePath;

  const PetDetailsScreen({
    super.key,
    required this.name,
    required this.price,
    required this.location,
    required this.imagePath,
  });

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
              Color(0xFFD1E8D6), // Light mint green
              Color(0xFFE4E6F1), // Light blue-grey
            ],
            stops: [0.4764, 0.8868],
            transform: GradientRotation(171.18 * 3.1416 / 180),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button and Details Text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Pet Image
              Container(
                width: double.infinity,
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Pet Information
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                location,
                                style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            price,
                            style: const TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2ECC71),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lovely and friendly pet looking for a new home. Well-trained and great with people.',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Seller Information',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                        ),
                        title: const Text(
                          'Sarah M.',
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Member since 2022',
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // ADD TO CART BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 3. This line finds the CartProvider and calls the addItem method
                            Provider.of<CartProvider>(context, listen: false).addItem(
                              name, // Using pet's name as a unique ID
                              name,
                              price,
                              imagePath,
                            );

                            // The SnackBar still provides user feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$name added to your cart!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9E6B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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