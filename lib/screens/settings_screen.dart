import 'package:bid/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserService userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _usernameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _usernameController = TextEditingController(
      text: user?.displayName ?? 'No username set',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateUsername() async {
    try {
      await _auth.currentUser?.updateDisplayName(_usernameController.text);
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update username: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = _auth.currentUser;
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final dividerColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        backgroundColor: backgroundColor,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.check, color: iconColor),
              onPressed: _updateUsername,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? Icon(Icons.person, color: iconColor) : null,
            ),
            title: _isEditing
                ? TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter new username',
                      hintStyle: TextStyle(color: subtitleColor),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: textColor),
                  )
                : Text(
                    user?.displayName ?? 'No username set',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
            subtitle: Text(
              user?.email ?? '',
              style: TextStyle(color: subtitleColor),
            ),
            trailing: IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: iconColor,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    _usernameController.text = user?.displayName ?? '';
                  }
                });
              },
            ),
          ),
          Divider(height: 32, color: dividerColor),
          Text(
            'Display Mode',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a display mode',
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeButton(
                  context: context,
                  icon: Icons.nightlight_round,
                  label: 'Dark Mode',
                  isSelected: isDarkMode,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildThemeButton(
                  context: context,
                  icon: Icons.wb_sunny,
                  label: 'Light Mode',
                  isSelected: !isDarkMode,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                ),
              ),
            ],
          ),
          Divider(height: 32, color: dividerColor),
          ListTile(
            title: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signin',
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: ${e.toString()}')),
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 3),
    );
  }

  Widget _buildThemeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        backgroundColor: isSelected
            ? (isDarkMode ? Colors.grey[800]! : Colors.blue[50]!)
            : (isDarkMode ? Colors.grey[900]! : Colors.white),
        foregroundColor: isSelected
            ? Theme.of(context).primaryColor
            : textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? Theme.of(context).primaryColor
                : (isDarkMode ? Colors.grey[300]! : Colors.grey[700]!),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : textColor,
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      backgroundColor: backgroundColor,
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
            Navigator.pushReplacementNamed(context, '/categories');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/watchlist');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/profile');
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