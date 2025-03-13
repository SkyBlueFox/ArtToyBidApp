import 'package:flutter/material.dart';

class WatchlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Watchlist')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Supreme x Kaws Chum'),
          ),
          ListTile(
            title: Text('Supreme x Kaws Chum'),
          ),
        ],
      ),
    );
  }
}