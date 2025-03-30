import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'cart_service.dart';

class OrderStatusScreen extends StatelessWidget {
  final String orderId;

  const OrderStatusScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final cardColor = themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;
    final dividerColor = themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    try {
      final order = CartService.orders.firstWhere(
        (order) => order['orderId'] == orderId,
      );

      final statusHistory = (order['statusHistory'] as List<dynamic>?) ?? [];

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Order #${order['orderId']}',
            style: TextStyle(color: textColor),
          ),
          backgroundColor: backgroundColor,
          iconTheme: IconThemeData(color: textColor),
        ),
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Current Status: ${order['status']}',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tracking #: ${order['trackingNumber']}',
                        style: TextStyle(color: textColor),
                      ),
                      Text(
                        'Order Date: ${order['date'].toString().split(' ')[0]}',
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Status Timeline',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              if (statusHistory.isEmpty)
                Text(
                  'No status updates available',
                  style: TextStyle(color: textColor),
                )
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
                              Text(
                                status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                message,
                                style: TextStyle(color: textColor.withOpacity(0.7)),
                              ),
                              Text(
                                date,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.5), 
                                  fontSize: 12),
                              ),
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: backgroundColor,
          iconTheme: IconThemeData(color: textColor),
        ),
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Order not found or data is corrupted',
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }
  }
}