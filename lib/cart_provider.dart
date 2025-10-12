import 'package:flutter/material.dart';

// This class defines what a single item in the cart looks like.
class CartItem {
  final String id;
  final String name;
  final String price;
  final String imagePath;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
  });
}

// This is the main class that manages all cart functions.
// It will hold a list of items and let you add or remove them.
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // A getter to access the items in the cart.
  Map<String, CartItem> get items {
    return {..._items};
  }

  // A getter to know how many items are in the cart.
  int get itemCount {
    return _items.length;
  }

  // The function to add a new pet to the cart.
  void addItem(String petId, String name, String price, String imagePath) {
    _items.putIfAbsent(
      petId, // Using the pet's name as a unique ID for now
      () => CartItem(
        id: DateTime.now().toString(),
        name: name,
        price: price,
        imagePath: imagePath,
      ),
    );
    // This is crucial! It tells any screen listening to the cart to update itself.
    notifyListeners();
  }

  // The function to remove a pet from the cart.
  void removeItem(String petId) {
    _items.remove(petId);
    notifyListeners();
  }
}