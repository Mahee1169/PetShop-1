import 'package:flutter/material.dart';

class CartItem {
  final String id; // Unique ID for the cart entry itself
  final int petId;  // ✅ ADDED: The integer ID of the pet from the database
  final String name;
  final String price;
  final String imagePath;

  CartItem({
    required this.id,
    required this.petId, // ✅ ADDED: Required in the constructor
    required this.name,
    required this.price,
    required this.imagePath,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  // ✅ UPDATED: The addItem function now requires the integer petId
  void addItem(int petId, String name, String price, String imagePath) {
    _items.putIfAbsent(
      petId.toString(), // Use the unique integer petId as the map key
      () => CartItem(
        id: DateTime.now().toString(),
        petId: petId, // ✅ ADDED: Pass the petId to the CartItem
        name: name,
        price: price,
        imagePath: imagePath,
      ),
    );
    notifyListeners();
  }

  void removeItem(String petId) {
    _items.remove(petId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}