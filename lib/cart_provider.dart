import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final int petId;  
  final String name;
  final String price;
  final String imagePath;

  CartItem({
    required this.id,
    required this.petId, 
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
  void addItem(int petId, String name, String price, String imagePath) {
    _items.putIfAbsent(
      petId.toString(), 
      () => CartItem(
        id: DateTime.now().toString(),
        petId: petId, 
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