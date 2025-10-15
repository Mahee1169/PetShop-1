import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedDistrict = 'Sylhet';

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
    final cart = Provider.of<CartProvider>(context);
    
    double total = 0.0;
    for (var item in cart.items.values) {
      String rawPrice = item.price.replaceAll('\$', '').replaceAll(',', '');
      total += double.tryParse(rawPrice) ?? 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.workSans()),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(_firstNameController, 'First Name'),
              _buildTextField(_lastNameController, 'Last Name'),
              _buildTextField(_addressController, 'Home Address'),
              _buildTextField(_cityController, 'Town / City'),
              _buildDistrictDropdown(),
              _buildTextField(_emailController, 'Email Address'),
              const SizedBox(height: 24),

              const Text('Additional Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(_notesController, 'Order notes (optional)', maxLines: 3),
              const SizedBox(height: 24),

              const Text('Your Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildOrderSummary(cart, total),
              const SizedBox(height: 32),

              _buildPlaceOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildOrderSummary(CartProvider cart, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...cart.items.values.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 40),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(item.price),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
            '৳${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71)),
            ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ THIS IS THE UPDATED WIDGET
  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Basic validation for required fields
          if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _addressController.text.isEmpty || _cityController.text.isEmpty || _emailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all customer details.'), backgroundColor: Colors.red),
            );
            return; // Stop if validation fails
          }

          // 1. GATHER ALL DATA INTO A MAP
          final checkoutData = {
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'address': _addressController.text.trim(),
            'city': _cityController.text.trim(),
            'district': _selectedDistrict,
            'email': _emailController.text.trim(),
            'notes': _notesController.text.trim(),
          };
          
          // 2. NAVIGATE TO PAYMENT SCREEN AND PASS THE DATA
          Navigator.pushNamed(context, '/payment', arguments: checkoutData);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9E6B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Place Order',
          style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}