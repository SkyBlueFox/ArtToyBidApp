import 'package:flutter/material.dart';

class IdentityVerificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify Identity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('We need to verify your identity before you can start bidding.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Scan ID with OCR
              },
              child: Text('Scan ID with OCR'),
            ),
            ElevatedButton(
              onPressed: () {
                // Upload ID Image
              },
              child: Text('Upload ID Image'),
            ),
            ElevatedButton(
              onPressed: () {
                // Enter Details Manually
              },
              child: Text('Enter Details Manually'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Continue
                Navigator.pushNamed(context, '/news_promotion');
              },
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}