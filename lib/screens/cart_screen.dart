import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'cart_service.dart';
import 'checkout_screen.dart';
import 'notification_service.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  CartScreen({
    super.key,
    List<Map<String, dynamic>>? cartItems,
  }) : cartItems = cartItems ?? CartService.cartItems;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
    _checkForWonAuctions();
  }

  void _checkForWonAuctions() {
    final wonAuctions = NotificationService.notifications
        .where((n) => n['category'] == 'Auction' && n['title'].contains('Won'))
        .toList();

    for (final auction in wonAuctions) {
      final productName = auction['title'].split('on ')[1];
      final amount = double.tryParse(
              auction['message'].split('\$')[1].split(' ')[0]) ??
          0.0;

      final existingIndex = _cartItems.indexWhere(
          (item) => item['name'] == productName && item['isAuction'] == true);

      if (existingIndex == -1) {
        setState(() {
          _cartItems.add({
            'name': productName,
            'price': amount,
            'isAuction': true,
            'quantity': 1,
            'status': 'Won',
          });
          CartService.addToCart({
            'name': productName,
            'price': amount,
            'isAuction': true,
            'quantity': 1,
            'status': 'Won',
          });
        });
      }
    }
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
      CartService.removeFromCart(index);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _cartItems[index]['quantity'] = newQuantity;
        if (index < CartService.cartItems.length) {
          CartService.cartItems[index]['quantity'] = newQuantity;
        }
      });
    } else {
      _removeItem(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: TextStyle(color: textColor),
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete, color: textColor),
              onPressed: () {
                setState(() {
                  CartService.clearCart();
                  _cartItems.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart cleared')),
                );
              },
            ),
        ],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart(context, textColor)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      final quantity = item['quantity'] ?? 1;
                      return _buildCartItem(item, index, quantity, context, textColor);
                    },
                  ),
                ),
                _buildCheckoutSection(context, textColor),
              ],
            ),
    );
  }

  Widget _buildCartItem(
    Map<String, dynamic> item,
    int index,
    int quantity,
    BuildContext context,
    Color textColor,
  ) {
    final isAuctionItem = item['isAuction'] == true;
    
    return Dismissible(
      key: Key('${item['name']}_${index.toString()}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => _removeItem(index),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: item['image'] != null
              ? Image.asset(
                  item['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      Icon(Icons.image, size: 50, color: textColor),
                )
              : Icon(
                  isAuctionItem ? Icons.gavel : Icons.shopping_cart,
                  size: 50,
                  color: textColor,
                ),
          title: Text(
            item['name'] ?? 'Unknown Item',
            style: TextStyle(color: textColor),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAuctionItem)
                Text(
                  'Won at \$${item['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Row(
                children: [
                  if (!isAuctionItem) ...[
                    IconButton(
                      icon: Icon(Icons.remove, color: textColor),
                      onPressed: () => _updateQuantity(index, quantity - 1),
                    ),
                    Text(
                      'Qty: $quantity',
                      style: TextStyle(color: textColor),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: textColor),
                      onPressed: () => _updateQuantity(index, quantity + 1),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    Text(
                      'Qty: 1 (Auction)',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeItem(index),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '\$${CartService.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _cartItems.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            selectedItems: List.from(_cartItems),
                          ),
                        ),
                      );
                    },
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/tracking');
            },
            child: Text(
              'View Order Tracking',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Continue Shopping',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/tracking');
            },
            child: Text(
              'View Order Tracking',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
