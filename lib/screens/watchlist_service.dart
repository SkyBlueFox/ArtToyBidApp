class WatchlistService {
  static final List<Map<String, String>> _watchlistItems = [
    {
      'name': 'Kaws x Sesame Street',
      'price': '\$4,000',
      'description': 'Limited edition collaboration between KAWS and Sesame Street characters',
    },
    {
      'name': 'Supreme x Kaws Chum',
      'price': '\$3,500',
      'description': 'Exclusive Supreme collaboration with KAWS Chum figure',
    },
  ];

  static bool isInWatchlist(String productName) {
    return _watchlistItems.any((item) => item['name'] == productName);
  }

  static void addToWatchlist(Map<String, String> product) {
    if (!isInWatchlist(product['name']!)) {
      _watchlistItems.add(product);
    }
  }

  static void removeFromWatchlist(String productName) {
    _watchlistItems.removeWhere((item) => item['name'] == productName);
  }

  static List<Map<String, String>> get watchlistItems => _watchlistItems;
}