import 'package:flutter/material.dart';
import 'cart_service.dart';

class OrderStatusScreen extends StatelessWidget {
  final String orderId;

  const OrderStatusScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    try {
      // Safe way to find order with null check
      final order = CartService.orders.firstWhere(
        (order) => order['orderId'] == orderId,
      );

      // Ensure statusHistory exists and is a List
      final statusHistory = (order['statusHistory'] as List<dynamic>?) ?? [];

      return Scaffold(
        appBar: AppBar(title: Text('Order #${order['orderId']}')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Current Status: ${order['status']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Tracking #: ${order['trackingNumber']}'),
                      Text('Order Date: ${order['date'].toString().split(' ')[0]}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Status timeline
              const Text('Status Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Safe timeline builder
              if (statusHistory.isEmpty)
                const Text('No status updates available')
              else
                ...statusHistory.map<Widget>((entry) {
                  final status = entry['status'] as String? ?? 'Unknown';
                  final message = entry['message'] as String? ?? '';
                  final date = entry['date'] is DateTime 
                      ? entry['date'].toString().split('.')[0]
                      : 'Unknown date';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(status,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(message),
                              Text(date,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      );
    } catch (e) {
      // Handle case where order is not found
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Order not found or data is corrupted'),
        ),
      );
    }
  }
}