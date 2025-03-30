import 'package:bid/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../services/google_drive_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final GoogleDriveService _driveService;
  User? _currentUser;
  File? _profileImage;
  bool _isUploading = false;
  late List<CameraDescription> _cameras;
  StreamSubscription<User?>? _authSubscription;
  List<Map<String, dynamic>> _biddingHistory = [];
  bool _isLoadingBids = true;
  StreamSubscription<QuerySnapshot>? _bidsSubscription;

  @override
  void initState() {
    super.initState();
    _driveService = GoogleDriveService();
    _initializeServices();
    _loadUser();
    _setupAuthListener();
    _setupBiddingHistoryListener();
  }

  Future<void> _initializeServices() async {
    try {
      _cameras = await availableCameras();
      await _driveService.initialize();
    } on CameraException catch (e) {
      _showErrorSnackbar('Camera Error: ${e.description}');
    } catch (e) {
      _showErrorSnackbar('Initialization Error: $e');
    }
  }

  void _setupBiddingHistoryListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoadingBids = true);

    _bidsSubscription = FirebaseFirestore.instance
        .collection('products')
        .where('currentBidderId', isEqualTo: userId)
        .orderBy('endTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _biddingHistory = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'productId': doc.id,
              'productName': data['name'] ?? 'Unknown Product',
              'amount': (data['currentBid'] as num?)?.toDouble() ?? 0.0,
              'timestamp': _parseDateString(data['endTime']),
              'status': _determineBidStatus(data, userId),
              'imageUrl': data['imageUrl'] ?? data['image'],
            };
          }).toList();
          _isLoadingBids = false;
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() => _isLoadingBids = false);
        _showErrorSnackbar('Failed to load bidding history: $e');
      }
    });
  }

  DateTime _parseDateString(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    
    try {
      if (dateValue.toString().contains('T')) {
        return DateTime.parse(dateValue.toString());
      }
      final formatted = dateValue.toString().replaceAll(' at ', ' ');
      return DateFormat('MMMM d, y h:mm:ss a z').parse(formatted);
    } catch (e) {
      return DateTime.now();
    }
  }

  String _determineBidStatus(Map<String, dynamic> productData, String userId) {
    final endTime = _parseDateString(productData['endTime']);
    final now = DateTime.now();
    final isAuctionEnded = endTime.isBefore(now);
    final isHighestBidder = productData['currentBidderId'] == userId;

    if (!isAuctionEnded) {
      return isHighestBidder ? 'Winning' : 'Outbid';
    } else {
      return isHighestBidder ? 'Won' : 'Lost';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _bidsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: backgroundColor,
        ),
        child: AlertDialog(
          title: Text(
            'Edit Profile Picture',
            style: TextStyle(color: textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: textColor),
                title: Text(
                  'Take Photo',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: textColor),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: textColor),
                ),
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

      final imageUrl = await _driveService.uploadProfileImage(
        imageFile,
        userId,
      );

      await _currentUser?.updatePhotoURL(imageUrl);
      await _refreshUser();

      if (mounted) {
        setState(() => _profileImage = imageFile);
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

      final success = await _driveService.deleteProfileImage(userId);
      if (!success) throw Exception('Failed to remove profile picture');

      await _currentUser?.updatePhotoURL(null);
      await _refreshUser();

      if (mounted) {
        setState(() => _profileImage = null);
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
    );
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
      _showErrorSnackbar('Error refreshing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final cardColor = themeProvider.isDarkMode ? Colors.grey[800]! : Colors.white;
    final dividerColor = themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    final user = FirebaseAuth.instance.currentUser;
    final dateFormat = DateFormat('MMM d, y - h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
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
      backgroundColor: backgroundColor,
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
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: textColor,
                              )
                            : null,
                      ),
                      if (!_isUploading)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? user?.email ?? 'Guest User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Joined ${dateFormat.format(user?.metadata.creationTime ?? DateTime.now())}',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/community');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, size: 20, color: textColor),
                          const SizedBox(width: 8),
                          Text(
                            'Community',
                            style: TextStyle(color: textColor),
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
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '4.5',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(5 reviews)',
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Bidding History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoadingBids)
                  Center(child: CircularProgressIndicator(color: textColor))
                else if (_biddingHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No bidding history yet',
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                  )
                else
                  Column(
                    children: _biddingHistory.map((bid) {
                      return Column(
                        children: [
                          ListTile(
                            leading: bid['imageUrl'] != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(bid['imageUrl']),
                                    radius: 20,
                                  )
                                : Icon(Icons.gavel, color: textColor),
                            title: Text(
                              'Bid \$${bid['amount'].toStringAsFixed(2)} on ${bid['productName']}',
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormat.format(bid['timestamp']),
                                  style: TextStyle(color: textColor.withOpacity(0.7)),
                                ),
                                const SizedBox(height: 4),
                                _buildBidStatusChip(bid['status'], textColor),
                              ],
                            ),
                            trailing: Icon(Icons.chevron_right, color: textColor),
                            onTap: () {
                              // Navigate to product detail page
                              // Navigator.push(context, MaterialPageRoute(
                              //   builder: (context) => ProductDetailPage(
                              //     productId: bid['productId'],
                              //   ),
                              // ));
                            },
                          ),
                          Divider(color: dividerColor),
                        ],
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          if (_isUploading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 3, themeProvider),
    );
  }

  Widget _buildBidStatusChip(String status, Color textColor) {
    Color chipColor;
    String displayText;
    
    switch (status.toLowerCase()) {
      case 'winning':
        chipColor = Colors.green;
        displayText = 'Currently Winning';
        break;
      case 'outbid':
        chipColor = Colors.orange;
        displayText = 'Outbid';
        break;
      case 'won':
        chipColor = Colors.green[800]!;
        displayText = 'Auction Won';
        break;
      case 'lost':
        chipColor = Colors.red;
        displayText = 'Auction Lost';
        break;
      default:
        chipColor = Colors.grey;
        displayText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(
    BuildContext context,
    int currentIndex,
    ThemeProvider themeProvider,
  ) {
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final selectedColor = Colors.blue;
    final unselectedColor = themeProvider.isDarkMode ? Colors.grey[500]! : Colors.grey;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final backgroundColor = themeProvider.isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Take Photo', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (widget.cameras.length > 1)
            IconButton(
              icon: Icon(Icons.cameraswitch, color: textColor),
              onPressed: _isInitializing ? null : _switchCamera,
            ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: _isInitializing
          ? Center(child: CircularProgressIndicator(color: textColor))
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
              : Center(
                  child: Text(
                    'Camera unavailable',
                    style: TextStyle(color: textColor),
                  ),
                ),
    );
  }
}