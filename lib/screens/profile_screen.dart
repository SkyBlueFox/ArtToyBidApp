import 'package:bid/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';
import '../services/google_drive_service.dart';
import 'notification_service.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final GoogleDriveService _driveService;
  bool _isDriveServiceInitialized = false;
  User? _currentUser;
  File? _profileImage;
  bool _isUploading = false;
  late List<CameraDescription> _cameras;
  StreamSubscription<User?>? _authSubscription;
  final String _googleDriveFolderId = '1i6JfYzdY5nMtZEhdk4o0qBzIsmN9DrMP';

  @override
  void initState() {
    super.initState();
    _driveService = GoogleDriveService();
    _initializeServices();
    _loadUser();
    _setupAuthListener();
  }

  Future<void> _initializeServices() async {
    try {
      _cameras = await availableCameras();
      await _driveService.initialize(folderId: _googleDriveFolderId);

      if (mounted) {
        setState(() {
          _isDriveServiceInitialized = true;
        });
      }
    } on CameraException catch (e) {
      _showErrorSnackbar('Camera Error: ${e.description}');
    } catch (e) {
      _showErrorSnackbar('Initialization Error: $e');
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    if (_cameras.isEmpty) {
      _showErrorSnackbar('No cameras available');
      return;
    }

    final imageFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          cameras: _cameras,
          onImageCaptured: (File imageFile) => imageFile,
        ),
      ),
    );

    if (imageFile != null && mounted) {
      await _uploadAndSetProfileImage(imageFile);
    }
  }

  Future<void> _uploadAndSetProfileImage(File imageFile) async {
    if (!mounted) return;

    setState(() => _isUploading = true);

    try {
      final userId = _currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final existingFileId = await _driveService.findUserProfileImage(userId);
      if (existingFileId != null) {
        final success = await _driveService.deleteProfileImage(existingFileId);
        if (!success) throw Exception('Failed to delete existing image');
      }

      final imageUrl = await _driveService.uploadProfileImage(imageFile, userId);
      if (imageUrl == null) throw Exception('Upload failed');

      await _currentUser?.updatePhotoURL(imageUrl);
      await _refreshUser();

      if (mounted) {
        setState(() {
          _profileImage = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Upload failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    if (!mounted) return;

    setState(() => _isUploading = true);
    try {
      final userId = _currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final fileId = await _driveService.findUserProfileImage(userId);
      if (fileId != null) {
        final success = await _driveService.deleteProfileImage(fileId);
        if (!success) throw Exception('Failed to delete from Drive');
      }

      await _currentUser?.updatePhotoURL(null);
      await _refreshUser();

      if (mounted) {
        setState(() {
          _profileImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to delete: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isUploading = true);

      if (Platform.isAndroid) {
        final PermissionStatus status = await Permission.photos.request();
        if (status.isPermanentlyDenied) {
          _showErrorSnackbar('Please enable photo access in Settings');
          return;
        }

        if (!status.isGranted) {
          await Permission.photos.request();
        }
      }

      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        requestFullMetadata: false,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        await _uploadAndSetProfileImage(imageFile);
      } else {
        _showErrorSnackbar('No image selected');
      }
    } on PlatformException catch (e) {
      _handlePixelSpecificError(e);
    } catch (e) {
      _showErrorSnackbar('Failed to access photos');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _handlePixelSpecificError(PlatformException e) {
    if (e.code == 'photo_access_denied') {
      _showErrorSnackbar(
        'Enable Photos access in Settings > Apps > [Your App] > Permissions',
      );
    } else {
      _showErrorSnackbar('Pixel photos access error: ${e.message}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _loadUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() => _currentUser = user);
      }
    });
  }

  Future<void> _refreshUser() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      _loadUser();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing: $e')),
      );
    }
  }

  Widget _buildBidHistoryItem(Map<String, dynamic> bid) {
    Color statusColor;
    IconData statusIcon;
    
    switch (bid['status']) {
      case 'Won':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Winning':
        statusColor = Colors.blue;
        statusIcon = Icons.arrow_upward;
        break;
      case 'Outbid':
        statusColor = Colors.orange;
        statusIcon = Icons.arrow_downward;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
    }

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.gavel),
          title: Text('Bid \$${bid['amount'].toStringAsFixed(2)} on ${bid['productName']}'),
          subtitle: Text(bid['date']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 4),
              Text(
                bid['status'],
                style: TextStyle(color: statusColor),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final biddingHistory = NotificationService.notifications
        .where((n) => n['category'] == 'Auction')
        .map((n) => {
              'productName': n['title'].contains('on ') 
                  ? n['title'].split('on ')[1] 
                  : 'Unknown Product',
              'amount': n['message'].contains('\$') 
                  ? double.tryParse(n['message'].split('\$')[1].split(' ')[0]) ?? 0.0
                  : 0.0,
              'date': DateFormat('MMM d, y').format(n['timestamp']),
              'status': n['title'].contains('Won') ? 'Won' : 'Winning',
            })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              await _refreshUser();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: !_isUploading ? _showImageSourceDialog : null,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : _currentUser?.photoURL != null
                                ? NetworkImage(_currentUser!.photoURL!)
                                : null,
                        child: _profileImage == null && _currentUser?.photoURL == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                      if (!_isUploading)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? user?.email ?? 'Guest User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Joined 2 weeks ago',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/community');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.people, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Community',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '4.5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 4),
                    Text('(5 reviews)'),
                  ],
                ),
                
                if (biddingHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Bidding History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ...biddingHistory.map((bid) => _buildBidHistoryItem(bid)).toList(),
                ] else ...[
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.gavel, size: 40, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No bidding history yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Participate in auctions to see your bidding activity here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isUploading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 3),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(
              context, '/home', (route) => false);
            break;
          case 1:
            Navigator.pushNamed(context, '/categories');
            break;
          case 2:
            Navigator.pushNamed(context, '/watchlist');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Watchlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
    );
  }
}

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(File) onImageCaptured;

  const CameraPage({
    super.key,
    required this.cameras,
    required this.onImageCaptured,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera(0);
  }

  Future<void> _initializeCamera(int index) async {
    if (!mounted || index >= widget.cameras.length) return;

    setState(() => _isInitializing = true);
    await _controller?.dispose();

    try {
      final newController = CameraController(
        widget.cameras[index],
        ResolutionPreset.medium,
      );

      await newController.initialize();

      if (!mounted) return;

      setState(() {
        _controller = newController;
        _selectedCameraIndex = index;
        _isInitializing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2 || _isInitializing) return;
    final newIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    await _initializeCamera(newIndex);
  }

  Future<void> _takePicture() async {
    if (_isInitializing || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final image = await _controller!.takePicture();
      if (!mounted) return;
      widget.onImageCaptured(File(image.path));
      Navigator.pop(context, File(image.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to take picture')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Photo'),
        actions: [
          if (widget.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _isInitializing ? null : _switchCamera,
            ),
        ],
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _controller != null && _controller!.value.isInitialized
              ? Stack(
                  children: [
                    CameraPreview(_controller!),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          onPressed: _takePicture,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(child: Text('Camera unavailable')),
    );
  }
}