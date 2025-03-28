import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bid/providers/theme_provider.dart';
import 'package:bid/screens/product_detail_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    final List<Map<String, dynamic>> promotions = [
      {
        'title': 'Summer Collection',
        'subtitle': 'Limited edition art toys',
        'image': 'assets/images/promo1.jpg',
        'product': {
          'name': 'KAWS Summer Edition',
          'price': 3200.0,
          'description': 'Special summer colorway of the iconic KAWS figure',
        }
      },
      {
        'title': 'New Arrivals',
        'subtitle': 'Fresh from the designers',
        'image': 'assets/images/promo2.jpg',
        'product': {
          'name': 'Bearbrick New Wave',
          'price': 2800.0,
          'description': 'Latest series from Medicom Toy',
        }
      },
    ];

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
            _buildPromoBanner(context, promotions),
            _buildSectionTitle('Recommendation', textColor),
            _buildRecommendationList(context),
            _buildSectionTitle('Popular Items', textColor),
            _buildPopularItems(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 0, isDarkMode),
    );
  }

  Widget _buildPromoBanner(BuildContext context, List<Map<String, dynamic>> promotions) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    product: promo['product'], 
                    productName: promo['product']['name'], 
                    onWatchlistChanged: () {},
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(promo['image'] ?? 'assets/images/default_promo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo['title'] ?? 'Promotion',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      promo['subtitle'] ?? 'Special offer',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _buildRecommendationList(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;

    final List<Map<String, dynamic>> recommendations = [
      {
        'name': 'Supreme x Kaws Chum',
        'price': 4000.0,
        'description': 'Limited edition collaboration figure',
        'image': 'assets/images/kaws_chum.jpg',
      },
      {
        'name': 'Bearbrick 400% Medicom',
        'price': 2500.0,
        'description': 'Collectible designer toy',
        'image': 'assets/images/bearbrick.jpg',
      },
      {
        'name': 'KAWS Companion',
        'price': 2800.0,
        'description': 'Classic KAWS Companion figure',
        'image': 'assets/images/kaws_companion.jpg',
      },
    ];

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          return _buildProductCard(recommendations[index], context, cardColor);
        },
      ),
    );
  }

  Widget _buildPopularItems(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;

    final List<Map<String, dynamic>> popularItems = [
      {
        'name': 'Kaws x Sesame Street',
        'price': 3500.0,
        'description': 'Exclusive collaboration with Sesame Street',
        'image': 'assets/images/kaws_sesame.jpg',
      },
      {
        'name': 'Funko Pop! Batman',
        'price': 50.0,
        'description': 'Limited edition Batman collectible',
        'image': 'assets/images/funko_batman.jpg',
      },
      {
        'name': 'Dunny Series',
        'price': 120.0,
        'description': 'Artist series collectible figures',
        'image': 'assets/images/dunny.jpg',
      },
      {
        'name': 'Supreme Box Logo',
        'price': 300.0,
        'description': 'Iconic Supreme box logo tee',
        'image': 'assets/images/supreme_tee.jpg',
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.8,
      padding: const EdgeInsets.all(8),
      children: popularItems.map((item) => _buildProductCard(item, context, cardColor)).toList(),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context, Color? cardColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              productName: product['name'] ?? 'Unknown',
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
                    ? Image.asset(
                        product['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
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
                  Text(
                    product['name'] ?? 'Unknown Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
}