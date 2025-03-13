import 'package:flutter/material.dart';

class PackageTrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Package')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Tracking Number: 1Z999AA1234567890'),
            Text('Estimated Delivery: Dec 18, by 8:00 PM'),
            SizedBox(height: 20),
            Text('Order Confirmed: Dec 15, 2023 • 10:30 AM'),
            Text('Package Processing: Dec 16, 2023 • 2:15 PM'),
            Text('In Transit: Dec 17, 2023 • 9:45 AM'),
            Text('Out for Delivery: Dec 18, 2023 • 8:00 AM'),
            Text('Delivered: Expected Dec 18 • by 6:00 PM'),
          ],
        ),
      ),
    );
  }
}