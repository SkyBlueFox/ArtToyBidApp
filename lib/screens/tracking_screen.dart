import 'package:flutter/material.dart';
import 'cart_service.dart';
import 'order_status_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: CartService.orders.isEmpty
          ? _buildEmptyOrders()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: CartService.orders.length,
              itemBuilder: (context, index) {
                final order = CartService.orders[index];
                return _buildOrderCard(order, context);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
    // Ensure all required fields exist
    final orderId = order['orderId'] as String? ?? 'N/A';
    final status = order['status'] as String? ?? 'Unknown';
    final items = order['items'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderStatusScreen(orderId: orderId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #$orderId',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Chip(
                    label: Text(status),
                    backgroundColor: _getStatusColor(status),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (items.isEmpty)
                const Text('No items information')
              else
                ...items.map<Widget>((item) {
                  final name = item['name'] as String? ?? 'Unknown item';
                  final quantity = item['quantity'] as int? ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $name (Qty: $quantity)'),
                  );
                }),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderStatusScreen(orderId: orderId),
                      ),
                    );
                  },
                  child: const Text('View Status Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.orange.shade100;
      case 'Shipped':
        return Colors.blue.shade100;
      case 'Delivered':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Widget _buildEmptyOrders() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No orders yet'),
          Text('Your completed orders will appear here',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}