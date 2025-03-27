class CartService {
  static final List<Map<String, dynamic>> _cartItems = [];
  static final List<Map<String, dynamic>> _orders = [];

  // Always returns a non-null list
  static List<Map<String, dynamic>> get cartItems => List.from(_cartItems);
  static List<Map<String, dynamic>> get orders => List.from(_orders);

  static void addToCart(Map<String, dynamic> product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['name'] == product['name'],
    );
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex]['quantity'] =
          (_cartItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      _cartItems.add({
        ...product,
        'quantity': 1,
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
      'statusHistory': [ // Initialize with empty array if null
        {
          'status': 'Processing',
          'date': DateTime.now(),
          'message': 'Order received and being prepared'
        }
      ] ?? [],
      'date': DateTime.now(),
      'trackingNumber': 'TRK-${DateTime.now().millisecondsSinceEpoch}',
      'items': orderDetails['items'] ?? [], // Ensure items is never null
    };
    _orders.add(order);
  }

  // Safe status update
  static void updateOrderStatus(String orderId, String status, String message) {
    final order = _orders.firstWhere(
      (o) => o['orderId'] == orderId,
      orElse: () => {},
    );
    
    if (order.isNotEmpty) {
      order['status'] = status;
      if (order['statusHistory'] == null) {
        order['statusHistory'] = [];
      }
      order['statusHistory'].add({
        'status': status,
        'date': DateTime.now(),
        'message': message
      });
    }
  }

  // Automatically progress order status (simulated)
  static void simulateOrderProgress() {
    for (var order in _orders) {
      if (order['status'] == 'Processing' && 
          DateTime.now().difference(order['date']).inHours > 2) {
        order['status'] = 'Shipped';
        order['statusHistory'].add({
          'status': 'Shipped',
          'date': DateTime.now(),
          'message': 'Package left our facility'
        });
      }
      else if (order['status'] == 'Shipped' && 
          DateTime.now().difference(order['date']).inDays > 2) {
        order['status'] = 'Delivered';
        order['statusHistory'].add({
          'status': 'Delivered',
          'date': DateTime.now(),
          'message': 'Package delivered successfully'
        });
      }
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
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }
}