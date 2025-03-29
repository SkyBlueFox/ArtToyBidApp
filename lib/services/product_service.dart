import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Create a new product
  Future<void> createProduct({
    required String name,
    required double price,
    required double startBid,
    required DateTime endTime,
    required String category, // More descriptive than 'type'
    required String sellType, // 'auction' or 'fixed-price'
    required String sellerId, // Essential for product ownership
  }) async {
    try {
      final docRef = _productsCollection.doc();

      await docRef.set({
        'productId': docRef.id, // Store document ID as a field
        'name': name.trim(),
        'price': price,
        'startBid': startBid,
        'currentBid': startBid, // Initialize with start bid
        'endTime': endTime,
        'category': category,
        'sellType': sellType,
        'imageUrl': "${docRef.id}.jpg",
        'sellerId': sellerId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active', // Track product state
      });
    } on FirebaseException catch (e) {
      throw _ProductException(
        code: e.code,
        message: 'Create failed: ${e.message}',
      );
    } catch (e) {
      throw _ProductException(code: 'UNKNOWN', message: 'An error occurred');
    }
  }

  // Get single product by ID
  Future<DocumentSnapshot> getProduct(String productId) async {
    try {
      return await _productsCollection.doc(productId).get();
    } on FirebaseException catch (e) {
      throw _ProductException(
        code: e.code,
        message: 'Read failed: ${e.message}',
      );
    }
  }

  // Get all products stream (real-time updates)
  Stream<QuerySnapshot> getAllProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get products by category
  Stream<QuerySnapshot> getProductsByCategory(String category) {
    return _productsCollection
        .where('category', isEqualTo: category.toLowerCase())
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

// Custom exception class
class _ProductException implements Exception {
  final String code;
  final String message;

  _ProductException({required this.code, required this.message});

  @override
  String toString() => 'ProductError[$code]: $message';
}
