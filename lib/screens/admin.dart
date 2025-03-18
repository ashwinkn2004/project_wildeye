import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_wildeye/quick_access/addcctv.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Logout function
  Future<void> _logout() async {
    try {
      await _auth.signOut(); // Sign out the user
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed. Please try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _logout,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'WildEye Admin',
          style: GoogleFonts.raleway(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout, size: 30),
          onPressed: _logout, // Call the logout function
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Admin Overview Section
            Center(
              child: Container(
                height: 198,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "  Admin Overview",
                      style: GoogleFonts.raleway(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "  Manage System",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Image(
                        image: AssetImage('assets/elephantBanner.png'),
                        height: 120,
                        width: 120,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 45),
              child: Text(
                "Quick Access",
                style: GoogleFonts.raleway(
                    fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Access Buttons (Priority Order)
            Row(
              children: [
                const SizedBox(width: 40),
                _buildQuickAccessCard(
                  icon: Icons.security,
                  color: Colors.blue,
                  text: "Authority\nNotification",
                  backgroundColor: Colors.blue.shade50,
                  onTap: () => Navigator.pushNamed(context, '/authorityNotification'),
                ),
                const SizedBox(width: 25),
                _buildQuickAccessCard(
                  icon: Icons.videocam_outlined,
                  color: Colors.green,
                  text: "Add\nCCTV",
                  backgroundColor: Colors.green.shade50,
                  onTap: () => AddCctvCamera(context),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Secondary Quick Access Buttons
            Row(
              children: [
                const SizedBox(width: 40),
                _buildQuickAccessCard(
                  icon: Icons.smart_display,
                  color: Colors.purple,
                  text: "Camera\nDetections",
                  backgroundColor: Colors.purple.shade50,
                  onTap: () => Navigator.pushNamed(context, '/cameraDetections'),
                ),
                const SizedBox(width: 25),
                _buildQuickAccessCard(
                  icon: Icons.report,
                  color: Colors.red,
                  text: "User\nReports",
                  backgroundColor: Colors.red.shade50,
                  onTap: () => Navigator.pushNamed(context, '/userReports'),
                ),
              ],
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),

      // Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerItem(Icons.dashboard, 'Dashboard', '/dashboard'),
            _buildDrawerItem(Icons.security, 'Users', '/userDetails'),
            _buildDrawerItem(Icons.person, 'Profile', '/profile'),
          ],
        ),
      ),
    );
  }

  // Quick Access Button
  Widget _buildQuickAccessCard({
    required IconData icon,
    required Color color,
    required String text,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 35),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                text,
                style: GoogleFonts.raleway(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group), label: 'Users'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.blue.shade50,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/dashboard');
                break;
              case 1:
                Navigator.pushNamed(context, '/userDetails');
                break;
              case 2:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          },
        ),
      ),
    );
  }

  // Drawer Items
  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}