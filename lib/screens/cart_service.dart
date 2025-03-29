class CartService {
  static final List<Map<String, dynamic>> _cartItems = [];
  static final List<Map<String, dynamic>> _orders = [];

  static List<Map<String, dynamic>> get cartItems => List.from(_cartItems);
  static List<Map<String, dynamic>> get orders => List.from(_orders);

  static void addToCart(Map<String, dynamic> product) {
    // For auction items, don't merge duplicates
    if (product['isAuction'] == true) {
      _cartItems.add(product);
      return;
    }

    // For regular products, merge duplicates
    final existingIndex = _cartItems.indexWhere(
      (item) => item['name'] == product['name'] && item['isAuction'] != true,
    );
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex]['quantity'] =
          (_cartItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      _cartItems.add({
        ...product,
        'quantity': product['quantity'] ?? 1,
        'isAuction': product['isAuction'] ?? false,
      });
    }
  }

  static void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
    }
  }

  static void clearCart() {
    _cartItems.clear();
  }

  static void placeOrder(Map<String, dynamic> orderDetails) {
    final order = {
      ...orderDetails,
      'orderId': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'Processing',
      'statusHistory': [
        {
          'status': 'Processing',
          'date': DateTime.now(),
          'message': 'Order received and being prepared'
        }
      ],
      'date': DateTime.now(),
      'trackingNumber': 'TRK-${DateTime.now().millisecondsSinceEpoch}',
      'items': orderDetails['items'] ?? [],
    };
    _orders.add(order);
    
    // Remove auction items from cart after purchase
    _cartItems.removeWhere((item) => item['isAuction'] == true);
  }

  static void updateOrderStatus(String orderId, String status, String message) {
    final order = _orders.firstWhere(
      (o) => o['orderId'] == orderId,
      orElse: () => {},
    );
    
    if (order.isNotEmpty) {
      order['status'] = status;
      order['statusHistory'].add({
        'status': status,
        'date': DateTime.now(),
        'message': message
      });
    }
  }

  static double _parsePrice(dynamic price) {
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }
    return 0.0;
  }

  static double get totalPrice {
    return _cartItems.fold(0, (sum, item) {
      final price = _parsePrice(item['price']);
      final quantity = item['isAuction'] == true ? 1 : (item['quantity'] ?? 1);
      return sum + (price * quantity);
    });
  }
}