import 'package:bid/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  File? _profileImage;
  bool _isUploading = false;
  late List<CameraDescription> _cameras;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
    _loadUser(); // Load initial data
    _setupAuthListener(); // Listen for future changes
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      _showErrorSnackbar('Camera Error: ${e.description}');
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      _deleteImage();
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CameraPage(
              cameras: _cameras, // Pass entire list
              onImageCaptured: (File imageFile) {
                setState(() => _profileImage = imageFile);
              },
            ),
      ),
    );
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
        requestFullMetadata: false, // Important for Pixel devices
      );

      if (pickedFile != null) {
        setState(() => _profileImage = File(pickedFile.path));
      } else {
        _showErrorSnackbar('No image selected');
      }
    } on PlatformException catch (e) {
      _handlePixelSpecificError(e);
    } catch (e) {
      debugPrint('Image picker error: $e');
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

  Future<void> _deleteImage() async {
    try {
      setState(() => _isUploading = true);
      setState(() {
        _profileImage = null;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      _showErrorSnackbar('Failed to delete image: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _loadUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() => _currentUser = user); // Update if auth state changes
      }
    });
  }

  Future<void> _refreshUser() async {
    try {
      await FirebaseAuth.instance.currentUser
          ?.reload(); // Force Firebase refresh
      _loadUser(); // Update UI
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error refreshing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                        child:
                            _profileImage == null
                                ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
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
                  user?.displayName ?? 'No username set',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    const Text(
                      '4.5',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                    const Text('(5 reviews)'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bidding history',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.gavel),
                  title: const Text('Placed a bid of \$150 on Takashi'),
                  subtitle: const Text('Apr 21, 2023'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.gavel),
                  title: const Text('Placed a bid of \$100 on Kaws, Open'),
                  subtitle: const Text('Apr 20, 2023'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          if (_isUploading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 3),
    );
  }

  BottomNavigationBar _buildBottomNavBar(
    BuildContext context,
    int currentIndex,
  ) {
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
              context,
              '/home',
              (route) => false,
            );
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
    _initializeCamera(0); // Start with first camera
  }

  Future<void> _initializeCamera(int index) async {
    if (!mounted || index >= widget.cameras.length) return;

    setState(() => _isInitializing = true);

    // Dispose previous controller if exists
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
    if (_isInitializing ||
        _controller == null ||
        !_controller!.value.isInitialized)
      return;

    try {
      final image = await _controller!.takePicture();
      if (!mounted) return;
      widget.onImageCaptured(File(image.path));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to take picture')));
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
      body:
          _isInitializing
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
