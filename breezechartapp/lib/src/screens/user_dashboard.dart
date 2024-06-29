import 'package:breezechartapp/src/screens/my_cart.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Your Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your action here
              },
              child: const Text('Button 1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add your action here
              },
              child: const Text('Button 2'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add your action here
              },
              child: const Text('Button 3'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to the cart page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()), // Navigate to the CartPage
                );
              },
              child: const Text('Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
