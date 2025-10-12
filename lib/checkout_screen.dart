import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart'; // Make sure to import your cart provider

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Controllers for the required text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Selected dropdown value for District
  String _selectedDistrict = 'Sylhet'; // Default value

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the cart from the provider to display items and total
    final cart = Provider.of<CartProvider>(context);
    
    // Calculate total price from the cart
    double total = 0.0;
    for (var item in cart.items.values) {
      String rawPrice = item.price.replaceAll('\$', '').replaceAll(',', '');
      total += double.tryParse(rawPrice) ?? 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFFD1E8D6), // Matching theme color
        elevation: 0,
      ),
      body: Container(
        // Using the same gradient as your other screens for consistency
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section for Customer Details
              const Text(
                'Customer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(_firstNameController, 'First Name'),
              _buildTextField(_lastNameController, 'Last Name'),
              _buildTextField(_addressController, 'Home Address'),
              _buildTextField(_cityController, 'Town / City'),
              _buildDistrictDropdown(), // Dropdown for district selection
              _buildTextField(_emailController, 'Email Address'),
              const SizedBox(height: 24),

              // Section for Additional Information
              const Text(
                'Additional Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(_notesController, 'Order notes (optional)', maxLines: 3),
              const SizedBox(height: 24),

              // Section for Order Summary
              const Text(
                'Your Order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildOrderSummary(cart, total), // Widget to show items and total
              const SizedBox(height: 32),

              // Final Place Order Button
              _buildPlaceOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for creating styled text fields
  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Helper widget for the District dropdown menu
  Widget _buildDistrictDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDistrict,
          isExpanded: true,
          items: <String>['Sylhet', 'Dhaka', 'Chittagong', 'Rajshahi', 'Khulna', 'Barisal']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDistrict = newValue!;
            });
          },
        ),
      ),
    );
  }

  // Helper widget to build the order summary section
  Widget _buildOrderSummary(CartProvider cart, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Display each item from the cart with a small picture
          ...cart.items.values.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  // Small Pet Picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Pet Name
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Pet Price
                  Text(item.price),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 24),
          // Display the total amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for the final "Place Order" button
  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        // ✅ THIS IS THE UPDATED PART
        onPressed: () {
          // Navigate to the payment screen
          Navigator.pushNamed(context, '/payment');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9E6B), // Matching theme button color
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Place Order',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}