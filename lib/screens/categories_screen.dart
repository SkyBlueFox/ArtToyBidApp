import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'product_detail_screen.dart';
import 'watchlist_service.dart';
import 'filtered_products_screen.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All',
    'Auction',
    'Buy Now',
    'Open Editions',
    'Sold'
  ];

  final List<String> _categories = [
    'Bearbrick',
    'Designer Toy',
    'Dunny',
    'Funko',
    'Kaws',
    'Supreme'
  ];

  final List<Map<String, dynamic>> _popularItems = [
    {
      'name': 'Supreme x Kaws Chum',
      'price': 4000.0,
      'description': 'Limited edition collaboration figure',
      'image': 'assets/images/kaws_chum.jpg',
      'type': 'Auction',
      'category': 'Kaws',
    },
    {
      'name': 'Bearbrick 400% Medicom',
      'price': 2500.0,
      'description': 'Collectible designer toy',
      'image': 'assets/images/bearbrick.jpg',
      'type': 'Buy Now',
      'category': 'Bearbrick',
    },
    {
      'name': 'KAWS Companion',
      'price': 2800.0,
      'description': 'Classic KAWS Companion figure',
      'image': 'assets/images/kaws_companion.jpg',
      'type': 'Auction',
      'category': 'Kaws',
    },
    {
      'name': 'Funko Pop! Batman',
      'price': 50.0,
      'description': 'Limited edition Batman collectible',
      'image': 'assets/images/funko_batman.jpg',
      'type': 'Buy Now',
      'category': 'Funko',
    },
  ];

  void _navigateToFilteredProducts(String filterType, String? category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredProductsPage(
          filterType: filterType,
          category: category,
          products: _getFilteredProducts(filterType, category),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredProducts(String filterType, String? category) {
    return _popularItems.where((item) {
      final matchesFilter = filterType == 'All' || item['type'] == filterType;
      final matchesCategory = category == null || item['category'] == category;
      return matchesFilter && matchesCategory;
    }).toList();
  }

  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Auction':
        return Colors.orange;
      case 'Buy Now':
        return Colors.green;
      case 'Open Editions':
        return Colors.purple;
      case 'Sold':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Bearbrick':
        return Icons.toys;
      case 'Designer Toy':
        return Icons.style;
      case 'Dunny':
        return Icons.palette;
      case 'Funko':
        return Icons.face;
      case 'Kaws':
        return Icons.brush;
      case 'Supreme':
        return Icons.star;
      default:
        return Icons.category;
    }
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    
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
          _navigateToFilteredProducts('All', title);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final price = _parsePrice(product['price']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
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
              product['name'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTypeColor(product['type']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product['type'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    WatchlistService.isInWatchlist(product['name'])
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      if (WatchlistService.isInWatchlist(product['name'])) {
                        WatchlistService.removeFromWatchlist(product['name']);
                      } else {
                        WatchlistService.addToWatchlist(product);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          WatchlistService.isInWatchlist(product['name'])
                              ? 'Added to watchlist'
                              : 'Removed from watchlist',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900] : Colors.white;
    final iconColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: iconColor,
      backgroundColor: backgroundColor,
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      backgroundColor: backgroundColor,
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
                        _navigateToFilteredProducts(_filters[index], null);
                      },
                      selectedColor: Colors.blue.withOpacity(0.2),
                      checkmarkColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: _selectedFilterIndex == index 
                            ? Colors.blue 
                            : textColor,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: _categories.map((category) {
                return _buildCategoryItem(category, _getCategoryIcon(category));
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Popular in Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
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
}