import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    double total = 0.0;
    for (var item in cart.items.values) {
      String rawPrice = item.price.replaceAll('\$', '').replaceAll(',', '');
      total += double.tryParse(rawPrice) ?? 0.0;
    }

    bool isDigitalPayment = _selectedPaymentMethod == PaymentMethod.bkash ||
        _selectedPaymentMethod == PaymentMethod.nagad;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Your Order'),
        backgroundColor: const Color(0xFFD1E8D6),
        elevation: 0,
      ),
      body: Container(
        // The background gradient now covers the whole screen
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
              // Total Amount Display
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
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Digital Payment Section
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

              // Direct Payment Section
              const Text('Direct Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPaymentOption(
                title: 'Cash on Delivery',
                value: PaymentMethod.cashOnDelivery,
              ),
              const SizedBox(height: 40),

              // Confirm Order Button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your order has been confirmed!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
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

  // ✅ THIS IS THE FULLY REBUILT WIDGET FOR THE PAYMENT OPTIONS
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (value != PaymentMethod.cashOnDelivery) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Number: $paymentNumber', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
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