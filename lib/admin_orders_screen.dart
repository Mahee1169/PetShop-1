import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchAllOrders();
  }
  Future<List<Map<String, dynamic>>> _fetchAllOrders() async {
    return await Supabase.instance.client
        .from('orders')
        .select()
        .order('created_at', ascending: false);
  }
  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus'), backgroundColor: Colors.green),
        );
        setState(() { _ordersFuture = _fetchAllOrders(); });
      }
    } catch (error) { /* Handle error */ }
  }
  Future<void> _deleteOrder(int orderId) async {
    try {
      await Supabase.instance.client.from('order_items').delete().eq('order_id', orderId);
      await Supabase.instance.client.from('orders').delete().eq('id', orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order deleted successfully'), backgroundColor: Colors.green),
        );
        setState(() { _ordersFuture = _fetchAllOrders(); });
      }
    } catch (error) { /* Handle error */ }
  }
  
  void _showDeleteConfirmation(int orderId) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Order?'),
      content: const Text('Are you sure you want to delete this order permanently?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        TextButton(onPressed: () { Navigator.of(ctx).pop(); _deleteOrder(orderId); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage All Orders', style: GoogleFonts.workSans())),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading orders.'));
          }
          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('No orders have been placed yet.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final formattedDate = DateFormat.yMMMd().format(DateTime.parse(order['created_at']));
              
              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order['id']} - \$${order['total_price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Customer: ${order['first_name']} ${order['last_name']}'),
                      Text('Date: $formattedDate'),
                      Text('Status: ${order['status']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                            onPressed: () => _showDeleteConfirmation(order['id']),
                            tooltip: 'Delete Order',
                          ),
                          const SizedBox(width: 8),
                          if(order['status'] == 'Processing')
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus(order['id'], 'Completed'),
                              child: const Text('Mark as Completed'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}