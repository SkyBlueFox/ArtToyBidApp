import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _productsCollection = 
      FirebaseFirestore.instance.collection('products');

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

  Future<void> updateProductDescription(String productId, String newDescription) async {
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
}

class _ProductException implements Exception {
  final String code;
  final String message;

  _ProductException({required this.code, required this.message});

  @override
  String toString() => 'ProductError[$code]: $message';
}