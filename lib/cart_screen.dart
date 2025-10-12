import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart'; // Make sure this import is correct

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) => Scaffold(
        appBar: AppBar(
          title: const Text('My Cart 🛒'),
          backgroundColor: const Color(0xFFD1E8D6), // Matching theme color
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFD1E8D6), // Light mint green
                Color(0xFFE4E6F1), // Light blue-grey
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: cart.itemCount == 0
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              'Your cart is empty!',
                              style: TextStyle(fontSize: 22, color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.itemCount,
                        itemBuilder: (ctx, i) {
                          final cartItem = cart.items.values.toList()[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(cartItem.imagePath),
                              ),
                              title: Text(
                                cartItem.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Price: ${cartItem.price}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                                tooltip: 'Remove from cart',
                                onPressed: () {
                                  Provider.of<CartProvider>(context, listen: false)
                                      .removeItem(cartItem.name);
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
      String rawPrice = item.price.replaceAll('\$', '').replaceAll(',', '');
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
                '\$${total.toStringAsFixed(2)}',
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
              // ✅ UPDATED ICON
              icon: const Icon(Icons.shopping_cart_checkout),
              // ✅ UPDATED TEXT
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