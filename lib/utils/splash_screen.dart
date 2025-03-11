import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:project_wildeye/screens/admin.dart';
import 'package:project_wildeye/screens/client.dart';
import 'package:project_wildeye/screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Method to determine the next screen after loading
  Future<void> _navigateToNextScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastRoute = prefs.getString('last_route');
    final User? user = FirebaseAuth.instance.currentUser;

    Widget nextScreen = const SignUpScreen(); // Default screen

    if (user != null) {
      // User is logged in, check their role
      final adminDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(user.uid)
          .get();
      final clientDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();

      if (adminDoc.exists) {
        // Save last route as admin
        await prefs.setString('last_route', '/admin');
        nextScreen = const AdminScreen();
      } else if (clientDoc.exists) {
        // Save last route as client
        await prefs.setString('last_route', '/client');
        nextScreen = const ClientScreen();
      }
    } else if (lastRoute != null) {
      // If no user is logged in but a last route exists, navigate to it
      switch (lastRoute) {
        case '/admin':
          nextScreen = const AdminScreen();
          break;
        case '/client':
          nextScreen = const ClientScreen();
          break;
        default:
          nextScreen = const SignUpScreen();
      }
    }

    // Navigate to the next screen after loading
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                      "WildEye",
                      style: GoogleFonts.raleway(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
            const SizedBox(height: 20),
            // Load Lottie animation from local assets
            Lottie.asset(
              'assets/loading.json', // Path to your Lottie JSON file
              width: 100, // Set width
              height: 100, // Set height
              fit: BoxFit.cover, // Adjust fit
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
