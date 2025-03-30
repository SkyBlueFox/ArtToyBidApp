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
    required String category,
    required String sellType,
    required String sellerId,
  }) async {
    try {
      final docRef = _productsCollection.doc();

      await docRef.set({
        'productId': docRef.id,
        'name': name.trim(),
        'price': price,
        'startBid': startBid,
        'currentBid': startBid,
        'currentBidderId': null,
        'endTime': endTime,
        'category': category,
        'sellType': sellType,
        'imageUrl': "${docRef.id}.jpg",
        'sellerId': sellerId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
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

  Future<void> updateBid({
    required String productId,
    required double newBid,
    required String bidderId,
  }) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final productRef = _productsCollection.doc(productId);
        final snapshot = await transaction.get(productRef);

        if (!snapshot.exists) {
          throw _ProductException(
            code: 'not-found',
            message: 'Product not found',
          );
        }

        final data = snapshot.data() as Map<String, dynamic>;

        // Validate product type
        if (data['sellType'] != 'auction') {
          throw _ProductException(
            code: 'invalid-type',
            message: 'Bidding only allowed for auction products',
          );
        }

        // Check product status
        if (data['status'] != 'active') {
          throw _ProductException(
            code: 'inactive',
            message: 'Auction is not active',
          );
        }

        // Check auction end time
        final endTime = (data['endTime'] as Timestamp).toDate();
        if (DateTime.now().isAfter(endTime)) {
          throw _ProductException(
            code: 'expired',
            message: 'Auction has already ended',
          );
        }

        // Validate bid amount
        final currentBid = data['currentBid'] as double;
        if (newBid <= currentBid) {
          throw _ProductException(
            code: 'low-bid',
            message: 'Bid must be higher than current bid of \$$currentBid',
          );
        }

        // Update the bid
        transaction.update(productRef, {
          'currentBid': newBid,
          'currentBidderId': bidderId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw _ProductException(
        code: e.code,
        message: 'Bid update failed: ${e.message}',
      );
    }
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
