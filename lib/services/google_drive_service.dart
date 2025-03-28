import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class GoogleDriveService {
  static final _instance = GoogleDriveService._internal();
  static const _scopes = [drive.DriveApi.driveFileScope];

  bool _isInitialized = false;
  late Map<String, dynamic> _credentials;
  String? _folderId;

  // Singleton pattern
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  Future<void> initialize({String? folderId}) async {
    if (_isInitialized) return;

    try {
      // Load credentials
      final jsonString = await rootBundle.loadString("assets/credentials.json");
      print(jsonString);
      _credentials = jsonDecode(jsonString);
      _folderId = folderId;
      _isInitialized = true;
      print('GoogleDriveService initialized successfully');
    } catch (e) {
      print('GoogleDriveService initialization failed: $e');
      throw Exception('Failed to initialize GoogleDriveService: $e');
    }
  }

  Future<drive.DriveApi> _getDriveApi() async {
    if (!_isInitialized) {
      throw Exception('GoogleDriveService must be initialized first');
    }

    try {
      final credentials = ServiceAccountCredentials.fromJson(_credentials);
      final client = await clientViaServiceAccount(credentials, _scopes);
      return drive.DriveApi(client);
    } catch (e) {
      print('Drive API creation failed: $e');
      throw Exception('Failed to create Drive API client: $e');
    }
  }

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final driveApi = await _getDriveApi();
      final fileName = 'profile_$userId${extension(imageFile.path)}';
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

      final file =
          drive.File()
            ..name = fileName
            ..parents = [_folderId!];

      print('Uploading $fileName to Google Drive...');
      final response = await driveApi.files.create(
        file,
        uploadMedia: drive.Media(
          imageFile.openRead(),
          imageFile.lengthSync(),
          contentType: mimeType,
        ),
      );

      print('Making file publicly accessible...');
      await driveApi.permissions.create(
        drive.Permission()
          ..role = 'reader'
          ..type = 'anyone',
        response.id!,
      );

      final imageUrl =
          'https://drive.google.com/uc?export=view&id=${response.id}';
      print('Upload successful! URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Upload failed: $e');
      rethrow;
    }
  }

  Future<bool> deleteProfileImage(String fileId) async {
    try {
      final driveApi = await _getDriveApi();
      print('Deleting file $fileId from Google Drive...');
      await driveApi.files.delete(fileId);
      print('Deletion successful');
      return true;
    } catch (e) {
      print('Deletion failed: $e');
      return false;
    }
  }

  Future<String?> findUserProfileImage(String userId) async {
    try {
      final driveApi = await _getDriveApi();
      print('Searching for profile image of user $userId...');
      final response = await driveApi.files.list(
        q: "'$_folderId' in parents and name contains 'profile_$userId'",
        spaces: 'drive',
        $fields: 'files(id)',
      );

      if (response.files?.isNotEmpty == true) {
        final fileId = response.files!.first.id;
        print('Found profile image with ID: $fileId');
        return fileId;
      }
      print('No profile image found for user $userId');
      return null;
    } catch (e) {
      print('Search failed: $e');
      rethrow;
    }
  }
}
