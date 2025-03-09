import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_wildeye/quick_access/addcctv.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white, // White app bar
        title: Text(
          'WildEye',
          style: GoogleFonts.raleway(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu_open_sharp, size: 30, color: Colors.black87),
          onPressed: () => Scaffold.of(context).openDrawer(),
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
                  color: Colors.blueGrey[50], // Light blue-grey
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "  In Emergency Call",
                      style: GoogleFonts.raleway(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    Text(
                      "  1800-425-4733",
                      style: GoogleFonts.montserrat(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
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
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ),
            SizedBox(height: 20),

            // Quick Access Buttons
            Row(
              children: [
                SizedBox(width: 40),
                _buildQuickAccessCard(
                  icon: Icons.videocam_outlined,
                  color: Colors.blueGrey[800]!, // Dark blue-grey
                  text: "Add\nCCTV",
                  backgroundColor: Colors.blueGrey[50]!, // Light blue-grey
                  onTap: () => AddCctvCamera(context),
                ),
                SizedBox(width: 25),
                _buildQuickAccessCard(
                  icon: Icons.add_alert,
                  color: Colors.red[800]!, // Dark red
                  text: "Emergency\nHelp",
                  backgroundColor: Colors.red[50]!, // Light red
                  onTap: () => Navigator.pushNamed(context, '/emergencyHelp'),
                ),
              ],
            ),
            SizedBox(height: 40),

            // Alert Buttons
            Row(
              children: [
                SizedBox(width: 40),
                _buildQuickAccessCard(
                  icon: Icons.notifications_active_outlined,
                  color: Colors.purple[800]!, // Dark purple
                  text: "Alert\nNotification",
                  backgroundColor: Colors.purple[50]!, // Light purple
                  onTap: () =>
                      Navigator.pushNamed(context, '/alertNotification'),
                ),
                SizedBox(width: 25),
                _buildQuickAccessCard(
                  icon: Icons.warning_amber_rounded,
                  color: Colors.amber[800]!, // Dark amber
                  text: "Alert\nNearby",
                  backgroundColor: Colors.amber[50]!, // Light amber
                  onTap: () => Navigator.pushNamed(context, '/alertNearby'),
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
          children: <Widget>[
            _buildDrawerItem(Icons.home, 'Home', '/home'),
            _buildDrawerItem(Icons.report, 'Report', '/report'),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
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
        color: Colors.white, // White background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8.0, offset: Offset(0, -4))
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
          selectedItemColor: Colors.blueGrey[800], // Dark blue-grey
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white, // White background
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
    );
  }

  // Drawer Items
  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: TextStyle(color: Colors.black87)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}