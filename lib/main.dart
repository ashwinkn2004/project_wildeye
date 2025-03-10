import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_wildeye/screens/signup.dart';
import 'package:project_wildeye/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_wildeye/screens/admin.dart'; // Import AdminScreen
import 'package:project_wildeye/screens/client.dart'; // Import ClientScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Method to determine the initial screen based on auth state
  Future<Widget> _getInitialScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastRoute = prefs.getString('last_route');
    final User? user = FirebaseAuth.instance.currentUser;

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
        return const AdminScreen();
      } else if (clientDoc.exists) {
        // Save last route as client
        await prefs.setString('last_route', '/client');
        return const ClientScreen();
      }
    }

    // If no user is logged in or no role found, go to SignUpScreen
    await prefs.remove('last_route'); // Clear last route if not logged in
    return const SignUpScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      // Use FutureBuilder to determine the initial screen
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ); // Show loading indicator while checking auth
          }
          return snapshot.data ?? const SignUpScreen(); // Default to SignUpScreen
        },
      ),
      routes: Routes.getRoutes(),
    );
  }
}