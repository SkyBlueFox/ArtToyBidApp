import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import 'watchlist_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All',
    'Auction',
    'Buy Now',
    'Open Editions',
    'Sold'
  ];

  final List<Map<String, dynamic>> _popularItems = [
    {
      'name': 'Supreme x Kaws Chum',
      'price': '\$4,000',
      'description': 'Limited edition collaboration figure',
      'image': 'assets/images/kaws_chum.jpg',
    },
    {
      'name': 'Bearbrick 400% Medicom',
      'price': '\$2,500',
      'description': 'Collectible designer toy',
      'image': 'assets/images/bearbrick.jpg',
    },
    {
      'name': 'KAWS Companion',
      'price': '\$2,800',
      'description': 'Classic KAWS Companion figure',
      'image': 'assets/images/kaws_companion.jpg',
    },
    {
      'name': 'Funko Pop! Batman',
      'price': '\$50',
      'description': 'Limited edition Batman collectible',
      'image': 'assets/images/funko_batman.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(_filters.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 8, 
                        right: index == _filters.length - 1 ? 0 : 8),
                    child: FilterChip(
                      label: Text(_filters[index]),
                      selected: _selectedFilterIndex == index,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFilterIndex = selected ? index : 0;
                        });
                      },
                      selectedColor: Colors.blue.withOpacity(0.2),
                      checkmarkColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: _selectedFilterIndex == index 
                            ? Colors.blue 
                            : Colors.black,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCategoryItem('Bearbrick', Icons.toys),
                _buildCategoryItem('Designer Toy', Icons.style),
                _buildCategoryItem('Dunny', Icons.palette),
                _buildCategoryItem('Funko', Icons.face),
                _buildCategoryItem('Kaws', Icons.brush),
                _buildCategoryItem('Supreme', Icons.star),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Popular in Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _popularItems.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(_popularItems[index], context);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 1),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle category tap
          // You could navigate to a filtered list screen here
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: {
                'name': product['name'],
                'price': product['price'],
                'description': product['description'],
              },
              onWatchlistChanged: () {
                setState(() {});
              },
              productName: product['name'],
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: product['image'] != null
                        ? Image.asset(
                            product['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product['name'] ?? 'Unknown Product',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              product['price'] ?? 'Price not available',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    WatchlistService.isInWatchlist(product['name'])
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      if (WatchlistService.isInWatchlist(product['name'])) {
                        WatchlistService.removeFromWatchlist(product['name']);
                      } else {
                        WatchlistService.addToWatchlist({
                          'name': product['name'],
                          'price': product['price'],
                          'description': product['description'],
                        });
                      }
                    });
                  },
                ),
              ],
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
            // Already on categories screen
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