import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) => Scaffold(
        appBar: AppBar(
          title: Text('My Cart 🛒', style: GoogleFonts.workSans()),
          backgroundColor: const Color(0xFFD1E8D6),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD1E8D6), Color(0xFFE4E6F1)],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: cart.itemCount == 0
                    ? Center(
                        child: Text('Your cart is empty!', style: GoogleFonts.workSans(fontSize: 18)),
                      )
                    : ListView.builder(
                        itemCount: cart.itemCount,
                        itemBuilder: (ctx, i) {
                          final cartItem = cart.items.values.toList()[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(cartItem.imagePath),
                                onBackgroundImageError: (exception, stackTrace) {
                                },
                              ),
                              title: Text(cartItem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Price: ${cartItem.price}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                                tooltip: 'Remove from cart',
                                onPressed: () {
                                  Provider.of<CartProvider>(context, listen: false)
                                      .removeItem(cartItem.petId.toString());
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (cart.itemCount > 0)
                _buildTotalAndCheckout(context, cart),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTotalAndCheckout(BuildContext context, CartProvider cart) {
    double total = 0.0;
    for (var item in cart.items.values) {
      String rawPrice = item.price.replaceAll('৳', '').replaceAll(',', '');
      total += double.tryParse(rawPrice) ?? 0.0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '৳${total.toStringAsFixed(2)}', 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/checkout');
              },
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text(
                'Checkout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9E6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}