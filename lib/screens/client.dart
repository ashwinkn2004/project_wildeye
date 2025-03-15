import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
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
        elevation: 0, // Remove shadow from AppBar
        title: Text(
          'WildEye',
          style: GoogleFonts.raleway(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout, size: 30),
          onPressed: _logout, // Call the logout function
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Emergency Call Section
            Center(
              child: Container(
                height: 198,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "  In Emergency Call",
                      style: GoogleFonts.raleway(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "  1800-425-4733",
                      style: GoogleFonts.montserrat(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            const phoneNumber = 'tel:18004254733';
                            if (await canLaunch(phoneNumber)) {
                              await launch(phoneNumber);
                            } else {
                              throw 'Could not launch $phoneNumber';
                            }
                          },
                          child: Image.asset('assets/callBanner.png',
                              width: 100, height: 100),
                        ),
                        SizedBox(width: 80),
                        SizedBox(
                          height: 110,
                          width: 110,
                          child: Image.asset('assets/elephantBanner.png'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 45),
              child: Text("Quick Access",
                  style: GoogleFonts.raleway(
                      fontSize: 26, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),

            // Quick Access Buttons (Priority Order)
            Row(
              children: [
                SizedBox(width: 40),
                _buildQuickAccessCard(
                  icon: Icons.notifications_active_outlined,
                  color: Colors.purple,
                  text: "Alert\nNotification",
                  backgroundColor: Colors.purple.shade50,
                  onTap: () => Navigator.pushNamed(context, '/alertNotification'),
                ),
                SizedBox(width: 25),
                _buildQuickAccessCard(
                  icon: Icons.group,
                  color: Colors.yellow.shade700,
                  text: "User\nNotifications",
                  backgroundColor: Colors.yellow.shade100,
                  onTap: () => Navigator.pushNamed(context, '/userNotification'),
                ),
              ],
            ),
            SizedBox(height: 40),

            // Authority Notifications and Emergency Help
            Row(
              children: [
                SizedBox(width: 40),
                _buildQuickAccessCard(
                  icon: Icons.admin_panel_settings,
                  color: Colors.blue,
                  text: "Authority\nNotification",
                  backgroundColor: Colors.blue.shade50,
                  onTap: () => Navigator.pushNamed(context, '/authorityNotification'),
                ),
                SizedBox(width: 25),
                _buildQuickAccessCard(
                  icon: Icons.add_alert,
                  color: Colors.red,
                  text: "Emergency\nHelp",
                  backgroundColor: Colors.pink.shade50,
                  onTap: () => Navigator.pushNamed(context, '/emergencyHelp'),
                ),
              ],
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
            currentIndex: _currentIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.blue.shade50,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (_currentIndex == 0)
                Navigator.pushNamed(context, '/home');
              else if (_currentIndex == 1)
                Navigator.pushNamed(context, '/report');
              else if (_currentIndex == 2)
                Navigator.pushNamed(context, '/profile');
            },
          ),
        ),
      ),

      // Drawer
      drawer: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildDrawerItem(Icons.home, 'Home', '/home'),
              _buildDrawerItem(Icons.report, 'Report', '/report'),
              _buildDrawerItem(Icons.person, 'Profile', '/profile'),
            ],
          ),
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
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 35),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 20),
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