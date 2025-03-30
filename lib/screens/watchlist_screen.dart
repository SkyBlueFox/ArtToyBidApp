import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import 'watchlist_service.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center( // Centered title
          child: Text(
            'Your Watchlist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true, // Ensure title is centered
      ),
      body: WatchlistService.watchlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No items in your watchlist',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon to add items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: WatchlistService.watchlistItems.length,
              itemBuilder: (context, index) {
                final item = WatchlistService.watchlistItems[index];
                return _buildWatchlistItem(item, context);
              },
            ),
      bottomNavigationBar: _buildBottomNavBar(context, 2),
    );
  }

  Widget _buildWatchlistItem(Map<String, dynamic> item, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                product: item,
                onWatchlistChanged: () {
                  setState(() {});
                },
                productName: item['name'] ?? '',
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Colors.grey.shade200,
              ),
              child: item['image'] != null
                  ? Image.asset(
                      item['image'],
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        'Product Image',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']?.toString() ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['description']?.toString() ?? 'No description',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            WatchlistService.removeFromWatchlist(item['name']?.toString() ?? '');
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex) {
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
                context, '/home', (route) => false);
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