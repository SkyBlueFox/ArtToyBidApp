import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Dark Mode'),
              value: false,
              onChanged: (value) {
                // Toggle Dark Mode
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Log Out
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}