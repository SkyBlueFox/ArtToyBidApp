import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'product_detail_screen.dart';
import 'watchlist_service.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor =
        themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final cardColor =
        themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;
    final dividerColor =
        themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Watchlist',
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
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: WatchlistService.getWatchlistStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading watchlist',
                style: TextStyle(color: textColor),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          final watchlistItems = snapshot.data ?? [];

          if (watchlistItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: textColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items in your watchlist',
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon to add items',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: watchlistItems.length,
            itemBuilder: (context, index) {
              final item = watchlistItems[index];
              final product = item.data() as Map<String, dynamic>;
              return _buildWatchlistItem(
                item.id,
                product,
                context,
                textColor: textColor,
                cardColor: cardColor,
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 2, themeProvider),
    );
  }

  Widget _buildWatchlistItem(
    String productId,
    Map<String, dynamic> product,
    BuildContext context, {
    required Color textColor,
    required Color cardColor,
  }) {
    final price = _parsePrice(product['price'] ?? product['startBid']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
              child:
                  product['image'] != null
                      ? Center(
                        child: Image.network(
                          'https://drive.google.com/uc?export=view&id=${product['image']}',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: textColor.withOpacity(0.5),
                                ),
                              ),
                        ),
                      )
                      : Center(
                        child: Text(
                          'Product Image',
                          style: TextStyle(color: textColor.withOpacity(0.5)),
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'No Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product['description'] ?? 'No description',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () async {
                          try {
                            await WatchlistService.removeFromWatchlist(
                              productId,
                            );
                            if (mounted) setState(() {});
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to remove: $e')),
                              );
                            }
                          }
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

  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  BottomNavigationBar _buildBottomNavBar(
    BuildContext context,
    int currentIndex,
    ThemeProvider themeProvider,
  ) {
    final backgroundColor =
        themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final selectedColor = Colors.blue;
    final unselectedColor =
        themeProvider.isDarkMode ? Colors.grey[500]! : Colors.grey;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
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
