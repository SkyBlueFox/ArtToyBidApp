import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'product_detail_screen.dart';
import 'watchlist_service.dart';

class FilteredProductsPage extends StatelessWidget {
  final String filterType;
  final String? category;
  final List<Map<String, dynamic>> products;

  const FilteredProductsPage({
    super.key,
    required this.filterType,
    this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode 
        ? Colors.grey[900]! // Non-null assertion
        : Colors.white;
    final cardColor = themeProvider.isDarkMode 
        ? Colors.grey[800]! // Non-null assertion
        : Colors.white;
    final secondaryTextColor = themeProvider.isDarkMode 
        ? Colors.grey[300]! // Non-null assertion
        : Colors.grey[600]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category != null 
              ? '$category - $filterType' 
              : filterType,
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
      body: products.isEmpty
          ? Center(
              child: Text(
                'No products found',
                style: TextStyle(color: textColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductItem(
                  product, 
                  context,
                  textColor: textColor,
                  cardColor: cardColor,
                  secondaryTextColor: secondaryTextColor,
                );
              },
            ),
    );
  }

  Widget _buildProductItem(
    Map<String, dynamic> product, 
    BuildContext context, {
    required Color textColor,
    required Color cardColor,
    required Color secondaryTextColor,
  }) {
    final price = _parsePrice(product['price']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                product: product,
                onWatchlistChanged: () {},
                productName: product['name'],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: product['image'] != null
                      ? Image.asset(
                          product['image'],
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image,
                          color: Colors.grey.shade400,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
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
                    Text(
                      product['description'],
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  WatchlistService.isInWatchlist(product['name'])
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  if (WatchlistService.isInWatchlist(product['name'])) {
                    WatchlistService.removeFromWatchlist(product['name']);
                  } else {
                    WatchlistService.addToWatchlist(product);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        WatchlistService.isInWatchlist(product['name'])
                            ? 'Added to watchlist'
                            : 'Removed from watchlist',
                        style: TextStyle(color: textColor),
                      ),
                      backgroundColor: cardColor,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
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
}