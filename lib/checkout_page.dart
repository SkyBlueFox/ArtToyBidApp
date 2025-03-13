import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Complete Your Purchase', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Selected Items'),
            Text('Art Toy Name \$49.99'),
            Text('Accessory Name \$49.99'),
            SizedBox(height: 20),
            Text('Shipping Method'),
            Text('Standard Shipping \$4.99'),
            Text('Express Shipping \$9.99'),
            Text('Next Day Delivery \$14.99'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Proceed to Payment
              },
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}