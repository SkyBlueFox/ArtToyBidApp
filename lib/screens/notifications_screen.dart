import 'package:flutter/material.dart';
import 'cart_service.dart';
import 'order_status_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildNotificationContent(context),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildNotificationContent(BuildContext context) {
    final orderNotifications = _getOrderStatusNotifications(context);
    
    return ListView(
      children: [
        if (orderNotifications.isNotEmpty) 
          _buildNotificationSection('ORDERS', orderNotifications),
          
        _buildNotificationSection('TODAY', [
          _buildNotificationItem(
            context: context,
            icon: Icons.gavel,
            title: 'Bid Accepted',
            subtitle: 'Your bid of \$250 was accepted for "Limited Edition Figure"',
            time: '2 minutes ago',
            category: 'Auction',
          ),
          _buildNotificationItem(
            context: context,
            icon: Icons.comment,
            title: 'New Comment',
            subtitle: '@artcollector commented: "Beautiful piece!"',
            time: '1 hour ago',
            category: 'Social',
          ),
        ]),
        
        _buildNotificationSection('YESTERDAY', [
          _buildNotificationItem(
            context: context,
            icon: Icons.payment,
            title: 'Payment Received',
            subtitle: 'You received \$180 for "Custom Figurine"',
            time: 'Yesterday at 15:30',
            category: 'Payment',
          ),
        ]),
        
        TextButton(
          onPressed: () {},
          child: const Text('Load more notifications'),
        ),
      ],
    );
  }

  List<Widget> _getOrderStatusNotifications(BuildContext context) {
    final notifications = <Widget>[];
    
    for (final order in CartService.orders) {
      final statusHistory = order['statusHistory'] as List<dynamic>? ?? [];
      
      for (final statusUpdate in statusHistory.reversed.take(3)) { // Show only latest 3 updates per order
        if (statusUpdate['date'] is DateTime) {
          final timeDiff = DateTime.now().difference(statusUpdate['date']);
          final status = statusUpdate['status']?.toString() ?? 'Update';
          
          notifications.add(
            _buildNotificationItem(
              context: context,
              icon: _getStatusIcon(status),
              title: 'Order #${order['orderId']} - $status',
              subtitle: statusUpdate['message']?.toString() ?? 'Order status updated',
              time: _formatTimeDifference(timeDiff),
              category: 'Order',
            ),
          );
        }
      }
    }
    
    return notifications;
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Icons.inventory;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimeDifference(Duration difference) {
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays}d ago';
  }

  Widget _buildNotificationSection(String title, List<Widget> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...notifications,
      ],
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String category,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getCategoryColor(category).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _getCategoryColor(category)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(subtitle),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryBackground(category),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getCategoryColor(category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        if (category == 'Order') {
          final orderId = title.split('#')[1].split(' -')[0].trim();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderStatusScreen(orderId: orderId),
            ),
          );
        }
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'order':
        return Colors.blue;
      case 'auction':
        return Colors.purple;
      case 'payment':
        return Colors.green;
      case 'social':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryBackground(String category) {
    return _getCategoryColor(category).withOpacity(0.1);
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(
            context, '/home', (route) => false);
        } else if (index == 1) {
          Navigator.pushNamed(context, '/categories');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/watchlist');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Watchlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
}