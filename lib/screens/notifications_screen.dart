import 'package:flutter/material.dart';
import 'notification_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService.notifications;

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
      body: notifications.isEmpty
          ? _buildEmptyNotifications()
          : _buildNotificationContent(context, notifications),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will see notifications here when you have updates',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContent(BuildContext context, List<Map<String, dynamic>> notifications) {
    return ListView(
      children: [
        _buildNotificationSection('RECENT', notifications.take(5).map((notification) {
          return _buildNotificationItem(
            context: context,
            icon: _getCategoryIcon(notification['category']),
            title: notification['title'],
            subtitle: notification['message'],
            time: _formatTimeDifference(DateTime.now().difference(notification['timestamp'])),
            category: notification['category'],
          );
        }).toList()),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'auction':
        return Icons.gavel;
      case 'order':
        return Icons.shopping_bag;
      case 'payment':
        return Icons.payment;
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