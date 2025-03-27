import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
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
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
      routes: {
        '/sign-in': (context) => const SignInPage(),
        '/verify': (context) => const VerifyIdentityPage(),
        '/home': (context) => const HomePage(),
        '/categories': (context) => const CategoriesPage(),
        '/product': (context) => const ProductDetailPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/tracking': (context) => const TrackingPage(),
        '/watchlist': (context) => const WatchlistPage(),
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
        '/community': (context) => const CommunityPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
