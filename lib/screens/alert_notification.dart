import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertNotification extends StatefulWidget {
  @override
  State<AlertNotification> createState() => _AlertNotificationState();
}

class _AlertNotificationState extends State<AlertNotification> {
  final List<Map<String, String>> alerts = [
    {
      "animal": "Tiger",
      "time": "23:12 3/1/25",
      "location": "Muthanga",
      "image":
          "https://imgs.search.brave.com/Q9Vch3fw0RIaoDGi5NWFWL6ciYWvKxJyypVLTIgtoxQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvOTU0/NTYwMjIyL3Bob3Rv/L2JsYWNrLXdoaXRl/LXRpZ2VyLmpwZz9z/PTYxMng2MTImdz0w/Jms9MjAmYz04elRq/RnlUbXQzWUNUN3RZ/RW14ZEhTRlQ0WGFj/elJoaHhDY1h1b2VU/aDJVPQ"
    },
    {
      "animal": "Elephant",
      "time": "23:12 3/1/25",
      "location": "Paralam",
      "image":
          "https://imgs.search.brave.com/0Ehbkp_L9rlMeOANF7bZe9y_P3FYlYraqaQJQgZqlwk/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9yZW5k/ZXIuZmluZWFydGFt/ZXJpY2EuY29tL2lt/YWdlcy9yZW5kZXJl/ZC9tZWRpdW0vcHJp/bnQvOC84L2JyZWFr/L2ltYWdlcy9hcnR3/b3JraW1hZ2VzL21l/ZGl1bS8xLzItYWZy/aWNhbi1lbGVwaGFu/dC1jbG9zZXVwLXNx/dWFyZS1zdXNhbi1z/Y2htaXR6LmpwZw"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Alert Notifications",
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: alerts.map((alert) => _buildAlertCard(alert)).toList(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildAlertCard(Map<String, String> alert) {
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Color(0xFFFDF9F3), // Soft Cream White
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inner Container (Attached to Outer Container - No Gaps)
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(0xFFE3F2E8), // Soft Mint Green
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(18)), // Attached Top
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    alert["image"]!,
                    width: 80, // Set a fixed width
                    height: 80, // Set a fixed height
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert["animal"]!,
                        style: GoogleFonts.raleway(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D), // Darker Grey-Black
                        )),
                    Text(alert["time"]!,
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          color: Color(0xFF555555), // Soft Grey
                        )),
                    Text(alert["location"]!,
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          color: Color(0xFF555555), // Soft Grey
                        )),
                  ],
                ),
              ],
            ),
          ),
          // Bottom Buttons (Image & Video) with Padding to Avoid Border Touching
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: _buildButton(
                        "Image", Icons.arrow_forward, Color(0xFF0D47A1), Color(0xFFDCE5F5))), // Deep Blue
                SizedBox(width: 16),
                Expanded(
                    child: _buildButton(
                        "Video", Icons.arrow_forward, Color(0xFFC62828), Color(0xFFF9DADA))), // Rich Red
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Color textColor, Color bgColor) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        // Handle action
      },
      icon: Icon(icon, size: 22),
      label: Text(
        text,
        style: GoogleFonts.raleway(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
