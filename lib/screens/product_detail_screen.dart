import 'package:flutter/material.dart';
import 'cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onWatchlistChanged;

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.onWatchlistChanged,
    required String productName,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailPage> {
  void _addToCartAndShowNotification(BuildContext context, bool isBuyNow) {
    // Add the product to cart with quantity 1
    CartService.addToCart({
      ...widget.product,
      'quantity': 1,
      'isBuyNow': isBuyNow,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product['name']} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            Navigator.pushNamed(
              context, 
              '/cart',
              arguments: {
                'cartItems': CartService.cartItems,
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              color: Colors.grey.shade200,
              child: Center(
                child: widget.product['image'] != null
                    ? Image.asset(
                        widget.product['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Text('Product Image'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'] ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['price'] ?? 'Price not available',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product['description'] ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.blue),
                      ),
                      onPressed: () {
                        _addToCartAndShowNotification(context, false);
                      },
                      child: const Text('Place Bid'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        _addToCartAndShowNotification(context, true);
                      },
                      child: const Text('Buy Now'),
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
}
