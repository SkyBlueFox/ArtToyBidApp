import 'package:flutter/material.dart';

class ProductGalleryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Gallery')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Bearbrick'),
            onTap: () {
              // Navigate to Bearbrick products
            },
          ),
          ListTile(
            title: Text('Designer Toy'),
            onTap: () {
              // Navigate to Designer Toy products
            },
          ),
          ListTile(
            title: Text('Dunny'),
            onTap: () {
              // Navigate to Dunny products
            },
          ),
          ListTile(
            title: Text('Funko'),
            onTap: () {
              // Navigate to Funko products
            },
          ),
        ],
      ),
    );
  }
}