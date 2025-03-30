import 'dart:async';
import 'package:bid/screens/cart_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'watchlist_service.dart';
import 'notification_service.dart';
import 'cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final VoidCallback onWatchlistChanged;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.onWatchlistChanged,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late DateTime auctionEndTime;
  late Duration remainingTime;
  Timer? _timer;
  double currentBid = 0.0;
  double minimumBid = 0.0;
  double buyNowPrice = 0.0;
  final TextEditingController _bidController = TextEditingController();
  bool isAuctionEnded = false;
  bool isLeadingBidder = false;
  bool isInWatchlist = false;
  List<Map<String, dynamic>> biddingHistory = [];
  Map<String, dynamic>? productData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadProductData();
    _checkWatchlistStatus();
  }

  Future<void> _loadProductData() async {
    try {
      final doc = await _firestore.collection('products').doc(widget.productId).get();
      if (doc.exists) {
        setState(() {
          productData = doc.data() as Map<String, dynamic>;
          minimumBid = _parsePrice(productData?['startBid'] ?? 0);
          currentBid = _parsePrice(productData?['currentBid'] ?? minimumBid);
          buyNowPrice = _parsePrice(productData?['price'] ?? 0);
          
          final endTime = productData?['endTime'] as Timestamp?;
          auctionEndTime = endTime?.toDate() ?? DateTime.now().add(const Duration(days: 3));
          remainingTime = auctionEndTime.difference(DateTime.now());
          
          _startTimer();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading product: $e')),
      );
    }
  }

  Future<void> _checkWatchlistStatus() async {
    isInWatchlist = await WatchlistService.isInWatchlist(widget.productId);
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        remainingTime = auctionEndTime.difference(DateTime.now());
        if (remainingTime.isNegative) {
          remainingTime = const Duration();
          isAuctionEnded = true;
          _timer?.cancel();
          _handleAuctionEnd();
        }
      });
    });
  }

  void _handleAuctionEnd() {
    _notifyAuctionEnded();
    if (isLeadingBidder) {
      _addWonAuctionToCart();
    }
  }

  void _addWonAuctionToCart() {
    if (productData == null) return;
    
    final auctionItem = {
      'productId': widget.productId,
      'name': productData?['name'],
      'price': currentBid,
      'imageUrl': productData?['imageUrl'],
      'isAuction': true,
      'quantity': 1,
      'status': 'Won',
    };
    
    CartService.addToCart(auctionItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${productData?['name']} added to your cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _notifyAuctionEnded() {
    if (productData == null) return;
    
    if (isLeadingBidder) {
      NotificationService.addNotification(
        title: 'Auction Won!',
        message: 'You won the auction for ${productData?['name']} with your bid of \$${currentBid.toStringAsFixed(2)}',
        category: 'Auction',
      );
    } else {
      NotificationService.addNotification(
        title: 'Auction Ended',
        message: 'The auction for ${productData?['name']} has ended',
        category: 'Auction',
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _toggleWatchlist() async {
    try {
      if (isInWatchlist) {
        await WatchlistService.removeFromWatchlist(widget.productId);
      } else {
        if (productData != null) {
          await WatchlistService.addToWatchlist(widget.productId, productData!);
        }
      }
      if (mounted) {
        setState(() {
          isInWatchlist = !isInWatchlist;
        });
        widget.onWatchlistChanged();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isInWatchlist ? 'Added to watchlist' : 'Removed from watchlist'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating watchlist: $e')),
      );
    }
  }

  Future<void> _placeBid() async {
    if (productData == null) return;
    
    final bidAmount = double.tryParse(_bidController.text) ?? 0.0;
    
    if (bidAmount < minimumBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid must be at least \$${minimumBid.toStringAsFixed(2)}'),
        ),
      );
      return;
    }

    if (bidAmount <= currentBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your bid must be higher than \$${currentBid.toStringAsFixed(2)}'),
        ),
      );
      return;
    }

    try {
      await _firestore.collection('products').doc(widget.productId).update({
        'currentBid': bidAmount,
        'lastBidder': FirebaseAuth.instance.currentUser?.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          currentBid = bidAmount;
          isLeadingBidder = true;
          _bidController.clear();
          
          biddingHistory.add({
            'productId': widget.productId,
            'amount': bidAmount,
            'date': DateFormat('MMM d, y').format(DateTime.now()),
            'status': isAuctionEnded ? 'Won' : 'Winning',
          });
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid of \$${bidAmount.toStringAsFixed(2)} placed successfully!'),
        ),
      );
      
      NotificationService.addNotification(
        title: 'Bid Placed',
        message: 'You placed a bid of \$${bidAmount.toStringAsFixed(2)} on ${productData?['name']}',
        category: 'Auction',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place bid: $e')),
      );
    }
  }

  void _buyNow() {
    if (productData == null) return;
    
    final productItem = {
      'productId': widget.productId,
      'name': productData?['name'],
      'price': buyNowPrice,
      'imageUrl': productData?['imageUrl'],
      'isAuction': false,
      'quantity': 1,
    };
    
    CartService.addToCart(productItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${productData?['name']} (\$${buyNowPrice.toStringAsFixed(2)}) added to cart!'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = twoDigits(duration.inDays);
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$days:$hours:$minutes:$seconds";
  }

  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (productData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final priceFormat = NumberFormat("#,##0.00", "en_US");

    return Scaffold(
      appBar: AppBar(
        title: Text(productData?['name'] ?? 'Product Details'),
        actions: [
          IconButton(
            icon: Icon(
              isInWatchlist ? Icons.favorite : Icons.favorite_border,
              color: isInWatchlist ? Colors.red : null,
            ),
            onPressed: _toggleWatchlist,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(),
                    ),
                  );
                },
              ),
              if (CartService.cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      CartService.cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              color: Colors.grey.shade200,
              child: Center(
                child: productData?['imageUrl'] != null
                    ? Image.network(
                        productData?['imageUrl']!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.broken_image, size: 100),
                      )
                    : const Icon(Icons.image, size: 100),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              productData?['name'] ?? 'Unknown Product',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minimum Bid: \$${priceFormat.format(minimumBid)}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Buy Now Price: \$${priceFormat.format(buyNowPrice)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Improved description display
            if (productData?['description'] != null && productData!['description'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  productData!['description'],
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      isAuctionEnded ? 'AUCTION ENDED' : 'TIME REMAINING',
                      style: TextStyle(
                        color: isAuctionEnded ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(remainingTime),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Days', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 24),
                        Text('Hours', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 24),
                        Text('Minutes', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 24),
                        Text('Seconds', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Bid: \$${priceFormat.format(currentBid)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLeadingBidder)
                      const Text(
                        'You are the highest bidder!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            if (!isAuctionEnded) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _bidController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter your bid (Min: \$${priceFormat.format(minimumBid)})',
                  prefixText: '\$',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _bidController.clear(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isAuctionEnded ? null : _placeBid,
                child: const Text('Place Bid'),
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: ElevatedButton(
                onPressed: _buyNow,
                child: Text('Buy Now \$${priceFormat.format(buyNowPrice)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}