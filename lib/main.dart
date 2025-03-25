import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/verify_identity_screen.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/community_screen.dart';

void main() => runApp(const ArtToyApp());

class ArtToyApp extends StatelessWidget {
  const ArtToyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Art Toy Bid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/verify': (context) => const VerifyIdentityScreen(),
        '/home': (context) => const HomeScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/product': (context) => const ProductDetailScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/watchlist': (context) => const WatchlistScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/community': (context) => const CommunityScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}