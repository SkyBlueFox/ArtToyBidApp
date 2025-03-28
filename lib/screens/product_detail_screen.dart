import 'package:bid/screens/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:bid/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:bid/providers/theme_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onWatchlistChanged;
  final String productName;

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.onWatchlistChanged,
    required this.productName,
  }) : super(key: key);

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

  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    minimumBid = _parsePrice(widget.product['minimumBid']);
    currentBid = _parsePrice(widget.product['currentBid']) ?? minimumBid;
    buyNowPrice = _parsePrice(widget.product['buyNowPrice']);

    auctionEndTime = DateTime.now().add(const Duration(days: 3));
    remainingTime = auctionEndTime.difference(DateTime.now());
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = auctionEndTime.difference(DateTime.now());
        if (remainingTime.isNegative) {
          remainingTime = const Duration();
          isAuctionEnded = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bidController.dispose();
    super.dispose();
  }

  void _placeBid() {
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

    setState(() {
      currentBid = bidAmount;
      isLeadingBidder = true;
      _bidController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bid of \$${bidAmount.toStringAsFixed(2)} placed successfully!'),
      ),
    );
  }

  void _buyNow() {
    CartService.addToCart({
      ...widget.product,
      'quantity': 1,
      'price': buyNowPrice,
      'isBuyNow': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product['name']} purchased for \$${buyNowPrice.toStringAsFixed(2)}'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.pushNamed(context, '/cart'),
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
    return "$days    $hours    $minutes    $seconds";
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final priceFormat = NumberFormat("#,##0.00", "en_US");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product['name'] ?? 'Product Details',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue[800],
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.white),
      ),
      body: Container(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Product Image
              Container(
                height: 300,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                child: Center(
                  child: widget.product['image'] != null
                      ? Image.asset(
                          widget.product['image']!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        )
                      : Icon(
                          Icons.image,
                          size: 100,
                          color: isDarkMode ? Colors.grey[400] : Colors.blue[200],
                        ),
                ),
              ),
              
              // Product Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      widget.product['name'] ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Price Information
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minimum Bid: \$${priceFormat.format(minimumBid)}',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.grey[300] : Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Buy Now Price: \$${priceFormat.format(buyNowPrice)}',
                          style: TextStyle(
                            fontSize: 20,
                            color: isDarkMode ? Colors.green[300] : Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Description
                    Text(
                      widget.product['description'] ?? 'No description available',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Auction Information Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Auction Status
                            Text(
                              isAuctionEnded ? 'AUCTION ENDED' : 'TIME REMAINING',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isAuctionEnded 
                                    ? Colors.red[400]
                                    : isDarkMode 
                                        ? Colors.blue[300] 
                                        : Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Countdown Timer
                            Text(
                              _formatDuration(remainingTime),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Timer Labels
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Days', style: TextStyle(
                                  fontSize: 12, 
                                  color: isDarkMode ? Colors.grey[300] : Colors.blue[800],
                                )),
                                const SizedBox(width: 24),
                                Text('Hours', style: TextStyle(
                                  fontSize: 12, 
                                  color: isDarkMode ? Colors.grey[300] : Colors.blue[800],
                                )),
                                const SizedBox(width: 24),
                                Text('Minutes', style: TextStyle(
                                  fontSize: 12, 
                                  color: isDarkMode ? Colors.grey[300] : Colors.blue[800],
                                )),
                                const SizedBox(width: 24),
                                Text('Seconds', style: TextStyle(
                                  fontSize: 12, 
                                  color: isDarkMode ? Colors.grey[300] : Colors.blue[800],
                                )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Current Bid
                            Text(
                              'Current Bid: \$${priceFormat.format(currentBid)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.blue[900],
                              ),
                            ),
                            
                            // Highest Bidder Indicator
                            if (isLeadingBidder)
                              Text(
                                'You are the highest bidder!',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.green[300] : Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bid Input Field (if auction is active)
                    if (!isAuctionEnded) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _bidController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Enter your bid (Min: \$${priceFormat.format(minimumBid)})',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.blue[800],
                          ),
                          prefixText: '\$',
                          prefixStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.blue[800],
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey[600]! : Colors.blue[400]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.blue[300]! : Colors.blue[800]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey[600]! : Colors.blue[400]!,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: isDarkMode ? Colors.grey[300] : Colors.blue[800],
                            ),
                            onPressed: () => _bidController.clear(),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(16),
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                child: Row(
                  children: [
                    // Place Bid Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: isDarkMode ? Colors.blue[300]! : Colors.blue[800]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: isDarkMode ? Colors.grey[800] : null,
                        ),
                        onPressed: isAuctionEnded ? null : _placeBid,
                        child: Text(
                          'Place Bid',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.blue[300] : Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Buy Now Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isDarkMode ? Colors.blue[800] : Colors.blue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _buyNow,
                        child: Text(
                          'Buy Now \$${priceFormat.format(buyNowPrice)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}