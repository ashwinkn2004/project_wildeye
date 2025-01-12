import 'package:flutter/material.dart';
import 'package:project_wildeye/screens/signup.dart';
import 'package:project_wildeye/utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Colors.white,
        home: SignUpScreen(),
        routes: Routes.getRoutes());
  }
}
