import 'package:flutter/material.dart';

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
      body: ListView(
        children: [
          _buildNotificationSection('TODAY', [
            _buildNotificationItem(
              icon: Icons.gavel,
              title: 'Bid Accepted',
              subtitle: 'Your bid of \$250 was accepted for "Limited Edition Figure"',
              time: '2 minutes ago',
              category: 'Auction',
            ),
            _buildNotificationItem(
              icon: Icons.comment,
              title: 'New Comment',
              subtitle: '@artcollector commented: "Beautiful piece!"',
              time: '1 hour ago',
              category: 'Social',
            ),
          ]),
          _buildNotificationSection('YESTERDAY', [
            _buildNotificationItem(
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
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...notifications,
      ],
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required String category,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Chip(
                label: Text(category),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: Colors.grey[200],
                labelStyle: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          Text(subtitle),
        ],
      ),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
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
          icon: Icon(Icons.home), 
          label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category), 
          label: 'Categories'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite), 
          label: 'Watchlist'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person), 
          label: 'Account'
        ),
      ],
    );
  }
}