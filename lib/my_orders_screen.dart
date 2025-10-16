import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late final Future<List<Map<String, dynamic>>> _myOrdersFuture;

  @override
  void initState() {
    super.initState();
    _myOrdersFuture = _fetchMyOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchMyOrders() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final data = await Supabase.instance.client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: GoogleFonts.workSans(fontWeight: FontWeight.w600)),
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _myOrdersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final myOrders = snapshot.data!;
            if (myOrders.isEmpty) {
              return Center(
                child: Text('You have not placed any orders yet.', style: GoogleFonts.workSans(fontSize: 18)),
              );
            }
            return ListView.builder(
              itemCount: myOrders.length,
              itemBuilder: (context, index) {
                final order = myOrders[index];
                final formattedDate = DateFormat.yMMMd().format(DateTime.parse(order['created_at']));
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Placed on $formattedDate - Status: ${order['status']}'),
                    trailing: Text('৳${order['total_price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}