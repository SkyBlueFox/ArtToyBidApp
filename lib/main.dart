import 'package:bid/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bid/providers/theme_provider.dart';
import 'package:bid/screens/sign_in_screen.dart';
import 'package:bid/screens/verify_identity_screen.dart';
import 'package:bid/screens/home_screen.dart';
import 'package:bid/screens/categories_page.dart';
import 'package:bid/screens/product_detail_screen.dart';
import 'package:bid/screens/notifications_screen.dart';
import 'package:bid/screens/cart_screen.dart';
import 'package:bid/screens/checkout_screen.dart';
import 'package:bid/screens/tracking_screen.dart';
import 'package:bid/screens/watchlist_screen.dart';
import 'package:bid/screens/settings_screen.dart';
import 'package:bid/screens/profile_screen.dart';
import 'package:bid/screens/community_screen.dart';
import 'package:bid/screens/filtered_products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const ArtToyApp(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize Firebase: $e'),
          ),
        ),
      ),
    );
  }
}

class ArtToyApp extends StatelessWidget {
  const ArtToyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
      title: 'Art Toy Bid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
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
      initialRoute: '/auth-check',
      routes: {
        '/auth-check': (context) => const AuthChecker(),
        '/signin': (context) => const SignInPage(),
        '/verify': (context) => const VerifyIdentityPage(),
        '/home': (context) => HomePage(),
        '/categories': (context) => const CategoriesPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/watchlist': (context) => const WatchlistPage(),
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
        '/community': (context) => const CommunityPage(),
        '/tracking': (context) => const TrackingPage(),
        '/cart': (context) =>  CartScreen(),
        '/filtered-products': (context) =>  FilteredProductsPage(
          filterType: 'All',
        ),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/product':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                productId: args['productId'],
                onWatchlistChanged: args['onWatchlistChanged'] ?? () {},
              ),
            );
          case '/checkout':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CheckoutPage(
                selectedItems: args['selectedItems'] ?? [],
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Error'),
                ),
                body: const Center(
                  child: Text('Page not found!'),
                ),
              ),
            );
        }
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Authentication error: ${snapshot.error}'),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const SignInPage();
        }

        if (!user.emailVerified) {
          return const VerifyIdentityPage();
        }

        return  HomePage();
      },
    );
  }
}