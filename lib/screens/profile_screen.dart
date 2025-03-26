import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lois Beckett',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Joined 2 weeks ago',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Follow',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/community');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.people, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Community', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                const Text(
                  '4.5',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 4),
                const Text('(5 reviews)'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Bidding history',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Placed a bid of \$150 on Takashi'),
              subtitle: const Text('Apr 21, 2023'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Placed a bid of \$100 on Kaws, Open'),
              subtitle: const Text('Apr 20, 2023'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 3),
    );
  }

  BottomNavigationBar _buildBottomNavBar(
    BuildContext context,
    int currentIndex,
  ) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
            break;
          case 1:
            Navigator.pushNamed(context, '/categories');
            break;
          case 2:
            Navigator.pushNamed(context, '/watchlist');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
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
