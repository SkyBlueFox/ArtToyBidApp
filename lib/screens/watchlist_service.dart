class WatchlistService {
  static List<Map<String, dynamic>> _watchlistItems = [];

  static List<Map<String, dynamic>> get watchlistItems => _watchlistItems;

  static void addToWatchlist(Map<String, dynamic> product) {
    // แก้ไขให้แปลงราคาก่อนบันทึก
    final productToAdd = {
      ...product,
      'price': _parsePrice(product['price']),
    };
    
    if (!_watchlistItems.any((item) => item['name'] == product['name'])) {
      _watchlistItems.add(productToAdd);
    }
  }

  static void removeFromWatchlist(String productName) {
    _watchlistItems.removeWhere((item) => item['name'] == productName);
  }

  static bool isInWatchlist(String productName) {
    return _watchlistItems.any((item) => item['name'] == productName);
  }

  static void clearWatchlist() {
    _watchlistItems.clear();
  }

  // เพิ่มเมธอดสำหรับแปลงราคา
  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}