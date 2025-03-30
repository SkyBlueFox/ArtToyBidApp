import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');

  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required double startBid,
    required DateTime endTime,
    required String type,
    required String sellType,
    required String image,
    required String sellerId,
  }) async {
    try {
      final docRef = _productsCollection.doc();
      await docRef.set({
        'productId': docRef.id,
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        'startBid': startBid,
        'currentBid': startBid,
        'currentBidderId': null,
        'endTime': endTime,
        'type': type,
        'sellType': sellType,
        'image': image,
        'sellerId': sellerId,
        'createdAt': FieldValue.serverTimestamp(),
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

  Stream<QuerySnapshot> getAllProducts() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getProductsBySellType(String sellType) {
    return _productsCollection
        .where('sellType', isEqualTo: sellType)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getProductsByType(String type) {
    return _productsCollection
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateProductDescription(
    String productId,
    String newDescription,
  ) async {
    try {
      await _productsCollection.doc(productId).update({
        'description': newDescription.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _ProductException(
        code: e.code,
        message: 'Update failed: ${e.message}',
      );
    }
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

  Future<void> updateExpiredProductsStatus() async {
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final querySnapshot = await _productsCollection
          .where('status', isEqualTo: 'active')
          .where('endTime', isLessThan: now)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'inactive',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw _ProductException(
        code: e.code,
        message: 'Status update failed: ${e.message}',
      );
    }
  }
}

class _ProductException implements Exception {
  final String code;
  final String message;

  _ProductException({required this.code, required this.message});

  @override
  String toString() => 'ProductError[$code]: $message';
}
