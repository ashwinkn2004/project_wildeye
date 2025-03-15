import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_wildeye/quick_access/user_report_details.dart'; // Import the details screen
import 'dart:convert'; // For Base64 decoding

class UserReportsScreen extends StatefulWidget {
  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User Reports",
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('userReport') // Fetch from userReport collection
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("Loading data...");
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              print("No data found.");
              return Center(
                child: Text(
                  'No reports found.',
                  style: GoogleFonts.raleway(fontSize: 18),
                ),
              );
            }

            if (snapshot.hasError) {
              print("Error fetching data: ${snapshot.error}");
              return Center(
                child: Text(
                  'Error fetching reports: ${snapshot.error}',
                  style: GoogleFonts.raleway(fontSize: 18),
                ),
              );
            }

            final reports = snapshot.data!.docs;
            print("Reports fetched: ${reports.length}");
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return _buildReportCard(reports[index]);
              },
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildReportCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final String animalName = data['animalName'] ?? 'Unknown';
    final String? timestamp = data['timestamp'];
    final String location = data['location'] ?? 'Unknown';
    final String image64 = data['image64'] ?? ''; // Base64 image
    final String description = data['description'] ?? 'No description';
    final String emailId = data['emailId'] ?? 'Unknown';
    final bool isVerified = data['verified'] ?? false;

    // Validate and decode Base64 image
    Widget imageWidget;
    try {
      if (image64.isNotEmpty) {
        // Check if the Base64 string is valid
        final decodedImage = base64Decode(image64);
        imageWidget = Image.memory(
          decodedImage,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );
      } else {
        // If Base64 string is empty, show an error icon
        imageWidget = Icon(Icons.error_outline, color: Colors.red);
      }
    } catch (e) {
      // If Base64 string is invalid, show an error icon
      print("Failed to decode Base64 image: $e");
      imageWidget = Icon(Icons.error_outline, color: Colors.red);
    }

    // Format timestamp
    String formattedTime = 'N/A';
    if (timestamp != null) {
      try {
        final DateTime dateTime = DateTime.parse(timestamp);
        formattedTime = DateFormat('HH:mm dd/MM/yy').format(dateTime);
      } catch (e) {
        print("Error parsing timestamp: $e");
        formattedTime = timestamp;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Image on the left
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          ),
          const SizedBox(width: 16),
          // Details in the middle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animalName,
                  style: GoogleFonts.raleway(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formattedTime,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  location,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          // View Icon on the right
          IconButton(
            icon: Icon(Icons.remove_red_eye, color: Colors.blue),
            onPressed: () {
              // Open details popup
              _showDetailsPopup(
                context,
                doc.id, // Pass the document ID
                image64,
                formattedTime,
                location,
                animalName,
                description,
                emailId,
                isVerified,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDetailsPopup(
    BuildContext context,
    String documentId, // Add documentId parameter
    String image64,
    String timestamp,
    String location,
    String animalName,
    String description,
    String emailId,
    bool isVerified,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return UserReportsDetails(
          image64: image64,
          timestamp: timestamp,
          location: location,
          animalName: animalName,
          description: description,
          emailId: emailId,
          isVerified: isVerified,
          documentId: documentId, // Pass the documentId
          onVerifyPressed: () async {
            // Update verification status in Firestoreaa
            await _firestore.collection('userReport').doc(documentId).update({
              'verified': true,
            });
          },
          onAlertPressed: () async {
            // Update alert status in Firestore
            await _firestore.collection('userReport').doc(documentId).update({
              'adminReply': true,
            });
          },
        );
      },
    );
  }
}
