import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_wildeye/quick_access/mobile_notifications.dart';
import 'package:project_wildeye/utils/routes.dart';
import 'package:project_wildeye/utils/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await AndroidAlarmManager.initialize(); // Initialize Android Alarm Manager
  initializeLocalNotifications(); // Initialize local notifications
  initializeFirebaseMessaging();
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
