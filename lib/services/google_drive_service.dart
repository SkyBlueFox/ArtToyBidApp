import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:mime/mime.dart';

class GoogleDriveService {
  static const _profileImagesFolderId = '1i6JfYzdY5nMtZEhdk4o0qBzIsmN9DrMP';
  static const _productImagesFolderId = '1fJiu7nuBwlMnTq96-HsoFxP6MITQnLzB';

  static final _instance = GoogleDriveService._internal();
  static const _scopes = [drive.DriveApi.driveFileScope];

  bool _isInitialized = false;
  late Map<String, dynamic> _credentials;

  factory GoogleDriveService() => _instance;

  GoogleDriveService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final jsonString = await rootBundle.loadString("assets/credentials.json");
      _credentials = jsonDecode(jsonString);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Google Drive initialization failed: $e');
    }
  }

  Future<drive.DriveApi> _getDriveApi() async {
    if (!_isInitialized) throw Exception('Service not initialized');
    final credentials = ServiceAccountCredentials.fromJson(_credentials);
    final client = await clientViaServiceAccount(credentials, _scopes);
    return drive.DriveApi(client);
  }

  // ================ Profile Image Operations ================
  Future<String> uploadProfileImage(File image, String userId) => 
      _uploadImage(image, 'profile_$userId', _profileImagesFolderId);

  Future<bool> deleteProfileImage(String userId) => 
      _deleteImage('profile_$userId', _profileImagesFolderId);

  Future<String?> findProfileImage(String userId) => 
      _findImage('profile_$userId', _profileImagesFolderId);

  // ================ Product Image Operations ================
  Future<String> uploadProductImage(File image, String productId) => 
      _uploadImage(image, 'product_$productId', _productImagesFolderId);

  Future<bool> deleteProductImage(String productId) => 
      _deleteImage('product_$productId', _productImagesFolderId);

  Future<String?> findProductImage(String productId) => 
      _findImage('product_$productId', _productImagesFolderId);

  // ======================= Core Methods ======================
  Future<String> _uploadImage(
    File image, 
    String fileName, 
    String folderId,
  ) async {
    try {
      final driveApi = await _getDriveApi();
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';

      // Delete existing image if exists
      await _deleteImage(fileName, folderId);

      // Create new file with forced .jpg extension
      final file = drive.File()
        ..name = '$fileName.jpg'
        ..parents = [folderId];

      final response = await driveApi.files.create(
        file,
        uploadMedia: drive.Media(
          image.openRead(),
          await image.length(),
          contentType: mimeType,
        ),
      );

      await _makeFilePublic(driveApi, response.id!);
      return 'https://drive.google.com/uc?export=view&id=${response.id}';
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }

  Future<bool> _deleteImage(String fileName, String folderId) async {
    try {
      final fileId = await _findImage(fileName, folderId);
      if (fileId == null) return true;

      final driveApi = await _getDriveApi();
      await driveApi.files.delete(fileId);
      return true;
    } catch (e) {
      print('Image deletion failed: $e');
      return false;
    }
  }

  Future<String?> _findImage(String fileName, String folderId) async {
    try {
      final driveApi = await _getDriveApi();
      final response = await driveApi.files.list(
        q: "'$folderId' in parents and name = '$fileName.jpg'",
        spaces: 'drive',
        $fields: 'files(id, name)',
      );
      return response.files?.firstOrNull?.id;
    } catch (e) {
      print('Image search failed: $e');
      return null;
    }
  }

  Future<void> _makeFilePublic(drive.DriveApi api, String fileId) async {
    await api.permissions.create(
      drive.Permission()
        ..role = 'reader'
        ..type = 'anyone',
      fileId,
    );
  }
}