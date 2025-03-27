import 'package:bid/firebase_options.dart';
import 'package:bid/screens/cart_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
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
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/signin' : '/home', // Fixed to match route name
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/verify': (context) => const VerifyIdentityPage(),
        '/home': (context) => const HomePage(),
        '/categories': (context) => const CategoriesPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/watchlist': (context) => const WatchlistPage(),
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfileScreen(),
        '/community': (context) => const CommunityPage(),
        '/tracking': (context) => const TrackingPage(),
        '/cart': (context) => CartScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/product':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                product: args['product'],
                onWatchlistChanged: args['onWatchlistChanged'],
                productName: args['productName'] ?? '',
              ),
            );
          case '/checkout':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CheckoutPage(
                selectedItems: args['selectedItems'],
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                  child: Text('Page not found!'),
                ),
              ),
            );
        }
      },
    );
  }
}