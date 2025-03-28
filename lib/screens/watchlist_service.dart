class WatchlistService {
  static List<Map<String, dynamic>> _watchlistItems = [];

  static List<Map<String, dynamic>> get watchlistItems => _watchlistItems;

  static void addToWatchlist(Map<String, dynamic> product) {
    if (!_watchlistItems.any((item) => item['name'] == product['name'])) {
      _watchlistItems.add(Map<String, dynamic>.from(product));
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
}