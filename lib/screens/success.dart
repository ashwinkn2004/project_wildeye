import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessPage extends StatelessWidget {
  final Future<String> future; // Future representing the login operations
  final String nextRoute; // Route to navigate to after the future completes

  const SuccessPage({
    super.key,
    required this.future,
    required this.nextRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Wait for the future to complete, then navigate to the next route
    future.then((route) {
      Navigator.pushReplacementNamed(context, route);
    }).catchError((error) {
      // Handle errors (e.g., show a snackbar and navigate back)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      Navigator.pop(context); // Go back to the previous screen
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: 150,
          width: 150,
          child: Lottie.asset('assets/loading.json'),
        ),
      ),
    );
  }
}