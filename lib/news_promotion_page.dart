import 'package:flutter/material.dart';

class NewsPromotionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News & Promotion')),
      body: ListView(
        children: [
          Image.asset('assets/news_image.png'), // Replace with actual image
          ListTile(
            title: Text('Recommendation'),
            subtitle: Text('Supreme x Kaws Chum'),
          ),
          ListTile(
            title: Text('Recommendation'),
            subtitle: Text('Supreme x Kaws Chum'),
          ),
        ],
      ),
    );
  }
}