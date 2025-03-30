import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'notification_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final cardColor = themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;
    final dividerColor = themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    final notifications = NotificationService.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      backgroundColor: backgroundColor,
      body: notifications.isEmpty
          ? _buildEmptyNotifications(textColor)
          : _buildNotificationContent(
              context, 
              notifications,
              textColor: textColor,
              cardColor: cardColor,
              dividerColor: dividerColor,
            ),
      bottomNavigationBar: _buildBottomNavBar(context, themeProvider),
    );
  }

  Widget _buildEmptyNotifications(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 60, color: textColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will see notifications here when you have updates',
            style: TextStyle(color: textColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContent(
    BuildContext context, 
    List<Map<String, dynamic>> notifications, {
    required Color textColor,
    required Color cardColor,
    required Color dividerColor,
  }) {
    return ListView(
      children: [
        _buildNotificationSection(
          'RECENT', 
          notifications.take(5).map((notification) {
            return _buildNotificationItem(
              context: context,
              icon: _getCategoryIcon(notification['category']),
              title: notification['title'],
              subtitle: notification['message'],
              time: _formatTimeDifference(DateTime.now().difference(notification['timestamp'])),
              category: notification['category'],
              textColor: textColor,
              cardColor: cardColor,
            );
          }).toList(),
          textColor: textColor,
        ),
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

  Widget _buildNotificationSection(String title, List<Widget> notifications, {required Color textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.7),
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
    required Color textColor,
    required Color cardColor,
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
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.5),
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

  BottomNavigationBar _buildBottomNavBar(BuildContext context, ThemeProvider themeProvider) {
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final selectedColor = Colors.blue;
    final unselectedColor = themeProvider.isDarkMode ? Colors.grey[500]! : Colors.grey;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
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