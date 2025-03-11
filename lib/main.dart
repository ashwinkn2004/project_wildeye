import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:project_wildeye/screens/signup.dart';
import 'package:project_wildeye/utils/routes.dart';
import 'package:project_wildeye/utils/splash_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: const SplashScreen(), // Show SplashScreen first
      routes: Routes.getRoutes(),
    );
  }
}

// SplashScreen widget
