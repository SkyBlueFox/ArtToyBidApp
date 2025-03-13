import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Joined 2 weeks ago'),
            Text('Rating: 4.5 ★★★★☆'),
            SizedBox(height: 20),
            Text('Bidding History'),
            Text('Placed a bid of \$150 on Takashi Apr 21, 2023'),
            Text('Placed a bid of \$100 on Kaws, Open Apr 20, 2023'),
          ],
        ),
      ),
    );
  }
}