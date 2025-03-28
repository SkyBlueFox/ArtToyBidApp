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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateUsername,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? const Icon(Icons.person) : null,
            ),
            title:
                _isEditing
                    ? TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter new username',
                        border: InputBorder.none,
                      ),
                    )
                    : Text(
                      user?.displayName ?? 'No username set',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
            subtitle: Text(user?.email ?? ''),
            trailing: IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
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
          const Divider(height: 32),
          const Text(
            'Display Mode',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a display mode',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeButton(
                  context: context,
                  icon: Icons.nightlight_round,
                  label: 'Dark Mode',
                  isSelected: themeProvider.isDarkMode,
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.dark);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildThemeButton(
                  context: context,
                  icon: Icons.wb_sunny,
                  label: 'Light Mode',
                  isSelected: !themeProvider.isDarkMode,
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.light);
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          ListTile(
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();

                // 3. Reset app state (example using Provider)
                // context.read<UserProvider>().clearUser();

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
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        backgroundColor:
            isSelected
                ? isDarkTheme
                    ? Colors
                        .grey[800] // Darker background for dark mode selection
                    : Colors
                        .blue[50] // Lighter background for light mode selection
                : theme.cardColor,
        foregroundColor:
            isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
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
            color:
                isSelected
                    ? theme.primaryColor
                    : isDarkTheme
                    ? Colors.grey[300]
                    : Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
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
