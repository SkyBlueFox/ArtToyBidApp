import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Bid Accepted'),
            subtitle: Text('Your bid of \$250 was accepted for "Limited Edition Figure"'),
          ),
          ListTile(
            title: Text('New Comment'),
            subtitle: Text('@artcollector commented: "Beautiful piece!"'),
          ),
        ],
      ),
    );
  }
}