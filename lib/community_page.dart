import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Announcements'),
            subtitle: Text('Important updates and news'),
          ),
          ListTile(
            title: Text('General Discussion'),
            subtitle: Text('Chat about anything art toy related'),
          ),
          ListTile(
            title: Text('Artist Corner'),
            subtitle: Text('Share your creations'),
          ),
        ],
      ),
    );
  }
}