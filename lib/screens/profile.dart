import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAFF), // Ultra-light sky blue
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3DAF1), // Very soft blue
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Color(0xFF6AAFE6)), // Muted soft blue
            ),
            const SizedBox(height: 10),
            const Text(
              "John Doe",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "johndoe@email.com",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            buildTextField("Phone Number", "9876543210", Icons.phone),
            buildTextField("Address", "123, Blue Street, NY", Icons.home),
            buildTextField("Date of Birth", "10 Oct 2000", Icons.calendar_today),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8D1F0), // Light sky blue
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Edit Profile", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6AAFE6)), // Muted soft blue
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
