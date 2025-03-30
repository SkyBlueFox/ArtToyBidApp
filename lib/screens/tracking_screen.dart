import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'cart_service.dart';
import 'order_status_screen.dart';
import 'package:intl/intl.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final cardColor = themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      backgroundColor: backgroundColor,
      body: CartService.orders.isEmpty
          ? _buildEmptyOrders(textColor)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: CartService.orders.length,
              itemBuilder: (context, index) {
                final order = CartService.orders[index];
                return _buildOrderCard(order, context, cardColor, textColor);
              },
            ),
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order, 
    BuildContext context,
    Color cardColor,
    Color textColor,
  ) {
    final orderId = order['orderId'] as String? ?? 'N/A';
    final status = order['status'] as String? ?? 'Unknown';
    final items = order['items'] as List<dynamic>? ?? [];
    final date = order['date'] is DateTime
        ? DateFormat('MMM d, y').format(order['date'])
        : 'Unknown date';

    return Card(
      color: cardColor,
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
                  Text(
                    'Order #$orderId',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Chip(
                    label: Text(
                      status,
                      style: TextStyle(color: _getStatusTextColor(status)),
                    ),
                    backgroundColor: _getStatusColor(status),
                  ),
                ],
              ),
              Text(
                date,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Items:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (items.isEmpty)
                Text(
                  'No items information',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                )
              else
                ...items.map<Widget>((item) {
                  final name = item['name'] as String? ?? 'Unknown item';
                  final quantity = item['quantity'] as int? ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• $name (Qty: $quantity)',
                      style: TextStyle(color: textColor),
                    ),
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
                  child: Text(
                    'View Status Details',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange.withOpacity(0.2);
      case 'shipped':
        return Colors.blue.withOpacity(0.2);
      case 'delivered':
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyOrders(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: textColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),
          ),
          Text(
            'Your completed orders will appear here',
            style: TextStyle(
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}