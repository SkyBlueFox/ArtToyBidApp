import 'package:bid/screens/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bid/providers/theme_provider.dart';
import 'package:bid/screens/sign_in_screen.dart';
import 'package:bid/screens/verify_identity_screen.dart';
import 'package:bid/screens/home_screen.dart';
import 'package:bid/screens/categories_screen.dart';
import 'package:bid/screens/product_detail_screen.dart';
import 'package:bid/screens/notifications_screen.dart';
import 'package:bid/screens/cart_screen.dart';
import 'package:bid/screens/checkout_screen.dart';
import 'package:bid/screens/tracking_screen.dart';
import 'package:bid/screens/watchlist_screen.dart';
import 'package:bid/screens/settings_screen.dart';
import 'package:bid/screens/profile_screen.dart';
import 'package:bid/screens/community_screen.dart';
import 'package:bid/services/cart_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Remove ChangeNotifierProvider for CartService since it's not a ChangeNotifier
        // CartService is used as a static class in your code
      ],
      child: const ArtToyApp(),
    ),
  );
}

class ArtToyApp extends StatelessWidget {
  const ArtToyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Art Toy Bid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/verify': (context) => const VerifyIdentityScreen(),
        '/home': (context) => const HomeScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/watchlist': (context) => const WatchlistScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/community': (context) => const CommunityScreen(),
        '/tracking': (context) => const TrackingScreen(),
        '/cart': (context) => CartScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/product':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                product: args['product'],
                onWatchlistChanged: args['onWatchlistChanged'],
                productName: args['productName'] ?? '',
              ),
            );
          case '/checkout':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                selectedItems: args['selectedItems'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}