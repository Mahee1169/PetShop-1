import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum PaymentMethod { bkash, nagad, cashOnDelivery }

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  final TextEditingController _referenceController = TextEditingController();
  bool _isLoading = false;

  Future<void> _confirmOrder() async {
    setState(() { _isLoading = true; });

    final checkoutData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final cart = Provider.of<CartProvider>(context, listen: false);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    
    double total = 0.0;
    for (var item in cart.items.values) {
      String rawPrice = item.price.replaceAll('৳', '').replaceAll(',', '');
      total += double.tryParse(rawPrice) ?? 0.0;
    }

    try {
      final orderData = await Supabase.instance.client.from('orders').insert({
        'user_id': userId,
        'total_price': total,
        'status': 'Processing',
        'first_name': checkoutData['first_name'],
        'last_name': checkoutData['last_name'],
        'address': checkoutData['address'],
        'city': checkoutData['city'],
        'district': checkoutData['district'],
        'email': checkoutData['email'],
        'notes': checkoutData['notes'],
      }).select().single();

      final orderId = orderData['id'];

      for (final item in cart.items.values) {
        await Supabase.instance.client.from('order_items').insert({
          'order_id': orderId,
          'pet_id': item.petId,
        });
      }
      
      cart.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${error.toString()}'), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    // ✅ FIX: Corrected the total price calculation
    double total = 0.0;
    for (var item in cart.items.values) {
      // Look for the Taka sign '৳' instead of '$'
      String rawPrice = item.price.replaceAll('৳', '').replaceAll(',', '');
      total += double.tryParse(rawPrice) ?? 0.0;
    }

    bool isDigitalPayment = _selectedPaymentMethod == PaymentMethod.bkash ||
        _selectedPaymentMethod == PaymentMethod.nagad;

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Your Order', style: GoogleFonts.workSans()),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD1E8D6), Color(0xFFE4E6F1)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount to Pay:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    // ✅ FIX: Display the total with the Taka sign
                    Text(
                      '৳${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Digital Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPaymentOption(
                title: 'bKash',
                logoPath: 'assets/images/bkash_logo.png',
                value: PaymentMethod.bkash,
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                title: 'Nagad',
                logoPath: 'assets/images/nagad_logo.png',
                value: PaymentMethod.nagad,
              ),
              const SizedBox(height: 16),

              if (isDigitalPayment)
                TextField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: 'bKash/Nagad Reference Note (TrxID)',
                    hintText: 'Enter your transaction ID here',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              const Text('Direct Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPaymentOption(
                title: 'Cash on Delivery',
                value: PaymentMethod.cashOnDelivery,
              ),
              const SizedBox(height: 40),

              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9E6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Confirm Order'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    String? logoPath,
    required PaymentMethod value,
  }) {
    const String paymentNumber = '01864827198';
    final bool isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9E6B) : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Radio<PaymentMethod>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue;
                });
              },
              activeColor: const Color(0xFFFF9E6B),
            ),
            if (logoPath != null) ...[
              Image.asset(logoPath, height: 24, width: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (value != PaymentMethod.cashOnDelivery) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Number: $paymentNumber', style: GoogleFonts.workSans(color: Colors.grey[700], fontSize: 12)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(const ClipboardData(text: paymentNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment number copied!')),
                            );
                          },
                          child: const Icon(Icons.copy, size: 14, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}