import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  // Create a new user document when registering
  Future<void> createUser({
    required String uid,
    String? profilePictureUrl,
    required DateTime joinedTime,
  }) async {
    try {
      await users.doc(uid).set({
        'uid': uid,
        'profilePicture': profilePictureUrl ?? '',
        'joinedTime': Timestamp.fromDate(joinedTime),
      });
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user data by UID
  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      return await users.doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user profile picture
  Future<void> updateProfilePicture({
    required String uid,
    required String newProfilePictureUrl,
  }) async {
    try {
      await users.doc(uid).update({
        'profilePicture': newProfilePictureUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }
}
