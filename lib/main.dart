import 'package:flutter/material.dart';
import 'auth_page.dart'; // หน้าเข้าสู่ระบบ
import 'identity_verification_page.dart'; // หน้า Verify Identity
import 'news_promotion_page.dart'; // หน้า News & Promotion
import 'product_gallery_page.dart'; // หน้า Product Gallery
import 'bidding_page.dart'; // หน้า Bidding
import 'notifications_page.dart'; // หน้า Notifications
import 'checkout_page.dart'; // หน้า Checkout
import 'package_tracking_page.dart'; // หน้า Track Package
import 'watchlist_page.dart'; // หน้า Watchlist
import 'settings_page.dart'; // หน้า Settings
import 'profile_page.dart'; // หน้า Profile
import 'community_page.dart'; // หน้า Community

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Art Toy Bid App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthPage(), // เริ่มต้นที่หน้าเข้าสู่ระบบ
      routes: {
        '/auth': (context) => AuthPage(),
        '/identity_verification': (context) => IdentityVerificationPage(),
        '/news_promotion': (context) => NewsPromotionPage(),
        '/product_gallery': (context) => ProductGalleryPage(),
        '/bidding': (context) => BiddingPage(),
        '/notifications': (context) => NotificationsPage(),
        '/checkout': (context) => CheckoutPage(),
        '/package_tracking': (context) => PackageTrackingPage(),
        '/watchlist': (context) => WatchlistPage(),
        '/settings': (context) => SettingsPage(),
        '/profile': (context) => ProfilePage(),
        '/community': (context) => CommunityPage(),
      },
    );
  }
}