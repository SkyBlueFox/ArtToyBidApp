import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category != null 
              ? '$category - $filterType' 
              : filterType,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: products.isEmpty
          ? const Center(
              child: Text('No products found'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductItem(product, context);
              },
            ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product['price'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['description'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}