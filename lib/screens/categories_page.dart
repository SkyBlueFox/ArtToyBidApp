import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    'Sold',
  ];

  final List<String> _categories = [
    'Bearbrick',
    'Designer Toy',
    'Dunny',
    'Funko',
    'Kaws',
    'Supreme',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _navigateToFilteredProducts(String filterType, String? category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FilteredProductsPage(
              filterType: filterType,
              category: category,
            ),
      ),
    );
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
        side: BorderSide(color: Colors.grey.shade300, width: 1),
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

  Widget _buildProductCard(DocumentSnapshot doc, BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final product = doc.data() as Map<String, dynamic>;
    final price = _parsePrice(product['price'] ?? product['startBid']);
    final productId = doc.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailPage(
                  productId: productId,
                  onWatchlistChanged: () {
                    setState(() {});
                  },
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
                    child:
                        product['image'] != null
                            ? Image.network(
                              'https://drive.google.com/uc?export=view&id=${product['image']}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
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
              product['name']?.toString() ?? 'Unknown Product',
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(product['sellType'] ?? 'Buy Now'),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product['sellType'] ?? 'Buy Now',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                FutureBuilder<bool>(
                  future: WatchlistService.isInWatchlist(productId),
                  builder: (context, snapshot) {
                    final isInWatchlist = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isInWatchlist ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () async {
                        try {
                          if (isInWatchlist) {
                            await WatchlistService.removeFromWatchlist(
                              productId,
                            );
                          } else {
                            await WatchlistService.addToWatchlist(
                              productId,
                              product,
                            );
                          }
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInWatchlist
                                    ? 'Removed from watchlist'
                                    : 'Added to watchlist',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
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

  BottomNavigationBar _buildBottomNavBar(
    BuildContext context,
    int currentIndex,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor =
        themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
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
              context,
              '/home',
              (route) => false,
            );
            break;
          case 1:
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
    final backgroundColor =
        themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;

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
                      right: index == _filters.length - 1 ? 0 : 8,
                    ),
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
                        color:
                            _selectedFilterIndex == index
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
              children:
                  _categories.map((category) {
                    return _buildCategoryItem(
                      category,
                      _getCategoryIcon(category),
                    );
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
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('products')
                        .orderBy('updatedAt', descending: true)
                        .limit(4)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(products[index], context);
                    },
                  );
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
