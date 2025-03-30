import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';
import 'product_detail_screen.dart';
import 'watchlist_service.dart';

class FilteredProductsPage extends StatelessWidget {
  final String filterType;
  final String? category;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FilteredProductsPage({
    super.key,
    required this.filterType,
    this.category,
  });

  Stream<QuerySnapshot> _getFilteredProductsStream() {
    Query query = _firestore.collection('products');

    // Case 1: Filter by both category and sellType
    if (category != null && filterType != 'All') {
      query = query
          .where('type', isEqualTo: category)
          .where('sellType', isEqualTo: filterType)
          .orderBy('type')
          .orderBy('sellType')
          .orderBy('updatedAt', descending: true);
    }
    // Case 2: Filter only by category
    else if (category != null) {
      query = query
          .where('type', isEqualTo: category)
          .orderBy('type')
          .orderBy('updatedAt', descending: true);
    }
    // Case 3: Filter only by sellType
    else if (filterType != 'All') {
      query = query
          .where('sellType', isEqualTo: filterType)
          .orderBy('sellType')
          .orderBy('updatedAt', descending: true);
    }
    // Case 4: No filters (show all)
    else {
      query = query.orderBy('updatedAt', descending: true);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode 
        ? Colors.grey[900]! 
        : Colors.white;
    final cardColor = themeProvider.isDarkMode 
        ? Colors.grey[800]! 
        : Colors.white;
    final secondaryTextColor = themeProvider.isDarkMode 
        ? Colors.grey[300]! 
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _getFilteredProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
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

          final products = snapshot.data?.docs ?? [];

          if (products.isEmpty) {
            return Center(
              child: Text(
                'No products found',
                style: TextStyle(color: textColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final product = productDoc.data() as Map<String, dynamic>;
              return _buildProductItem(
                productDoc.id,
                product, 
                context,
                textColor: textColor,
                cardColor: cardColor,
                secondaryTextColor: secondaryTextColor,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductItem(
    String productId,
    Map<String, dynamic> product, 
    BuildContext context, {
    required Color textColor,
    required Color cardColor,
    required Color secondaryTextColor,
  }) {
    final price = _parsePrice(product['price'] ?? product['startBid']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      child: InkWell(
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
                      ? Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.broken_image),
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
                      product['name']?.toString() ?? 'Unknown Product',
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
                      product['description']?.toString() ?? 'No description available',
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
              FutureBuilder<bool>(
                future: WatchlistService.isInWatchlist(productId),
                builder: (context, snapshot) {
                  final isInWatchlist = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isInWatchlist ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      try {
                        if (isInWatchlist) {
                          await WatchlistService.removeFromWatchlist(productId);
                        } else {
                          await WatchlistService.addToWatchlist(productId, product);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isInWatchlist
                                  ? 'Removed from watchlist'
                                  : 'Added to watchlist',
                              style: TextStyle(color: textColor),
                            ),
                            backgroundColor: cardColor,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                          ),
                        );
                      }
                    },
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