import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bid/providers/theme_provider.dart';
import 'package:bid/screens/product_detail_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'NEWS & Promotion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: iconColor),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          color: iconColor,
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            color: iconColor,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: iconColor,
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPromoBanner(context),
            _buildSectionTitle('Recommendation', textColor),
            _buildRecommendationList(context, textColor),
            _buildSectionTitle('Popular Items', textColor),
            _buildPopularItems(context, textColor),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 0, isDarkMode),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('promotions').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading promotions', style: TextStyle(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final promotions = snapshot.data?.docs ?? [];

        if (promotions.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No promotions available')),
          );
        }

        return SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promo = promotions[index].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(promo['imageUrl'] ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList(BuildContext context, Color textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products')
          .where('sellType', isEqualTo: 'Auction')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'Failed to load recommendations',
                style: TextStyle(color: textColor),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final recommendations = snapshot.data?.docs ?? [];

        if (recommendations.isEmpty) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                'No recommendations available',
                style: TextStyle(color: textColor),
              ),
            ),
          );
        }

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final product = recommendations[index].data() as Map<String, dynamic>;
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildProductCard(
                  product, 
                  context, 
                  cardColor,
                  recommendations[index].id,
                  textColor: textColor,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPopularItems(BuildContext context, Color textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load products',
              style: TextStyle(color: textColor),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data?.docs ?? [];

        if (products.isEmpty) {
          return Center(
            child: Text(
              'No products available',
              style: TextStyle(color: textColor),
            ),
          );
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          padding: const EdgeInsets.all(8),
          children: products.map((doc) {
            final product = doc.data() as Map<String, dynamic>;
            return _buildProductCard(
              product, 
              context, 
              cardColor,
              doc.id,
              textColor: textColor,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product, 
    BuildContext context, 
    Color? cardColor,
    String productId, {
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              productId: productId,
              onWatchlistChanged: () {},
            ),
          ),
        );
      },
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: product['image'] != null
                    ? Image.network(
                        product['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: Text(
                      product['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product['sellType'] == 'Auction') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Auction',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex, bool isDarkMode) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
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
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
}