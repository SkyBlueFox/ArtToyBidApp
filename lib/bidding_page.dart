import 'package:flutter/material.dart';

class BiddingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bidding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Kaws x Sesame Street', style: TextStyle(fontSize: 24)),
            Text('\$4,000', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Place Bid
                  },
                  child: Text('Place Bid'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Buy Now
                  },
                  child: Text('Buy Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}