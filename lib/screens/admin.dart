import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin',),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Admin Screen', style: TextStyle(fontSize: 20)),
      ),
      backgroundColor: Colors.white,
    );
  }
}