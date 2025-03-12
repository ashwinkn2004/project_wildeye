import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'dart:io';

import 'package:project_wildeye/quick_access/user_report_details.dart';

class UserReportsScreen extends StatefulWidget {
  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      Placemark place = placemarks[0];
      return "${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return "Unknown Location";
    }
  }

  Future<void> submitReport({
    required String animalName,
    required String description,
    required String emailId,
    required String image64,
    required String location,
  }) async {
    await _firestore.collection('userReport').add({
      'adminReply': false,
      'animalName': animalName,
      'description': description,
      'emailId': emailId,
      'image64': image64,
      'location': location,
      'verified': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

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
              .collection('detections')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No detections found.',
                  style: GoogleFonts.raleway(fontSize: 18),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching detections: ${snapshot.error}',
                  style: GoogleFonts.raleway(fontSize: 18),
                ),
              );
            }

            final alerts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertCard(alerts[index]);
              },
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildAlertCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final String label = data['label'] ?? 'Unknown';
    final String? timestamp = data['timestamp'];
    final String location = data['location'] ?? 'Unknown';
    final String imageUrl = data['image_url'] ?? 'https://via.placeholder.com/80';
    final String videoUrl = data['video_url'] ?? '';

    String formattedTime = 'N/A';
    if (timestamp != null) {
      try {
        final DateTime dateTime = DateFormat('HH:mm d/M/yy').parse(timestamp);
        formattedTime = DateFormat('HH:mm dd/MM/yy').format(dateTime);
      } catch (e) {
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
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error_outline, color: Colors.red);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Details in the middle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
          // Cross Icon and View Icon on the right
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  // Add functionality to delete or dismiss the detection
                },
              ),
              IconButton(
                icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                onPressed: () {
                  // Open details popup
                  _showDetailsPopup(context, imageUrl, videoUrl, formattedTime, location);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetailsPopup(BuildContext context, String imageUrl, String videoUrl, String timestamp, String location) {
    bool isVerified = false; // Initially false

    showDialog(
      context: context,
      builder: (context) {
        return UserReportsDetails(
          imageUrl: imageUrl,
          videoUrl: videoUrl,
          timestamp: timestamp,
          location: location,
          name: "Dummy Value",
          description: "Hii",
          emailId: "dummy@gmail.com",
          isVerified: isVerified,
          onVerifyPressed: () {
            setState(() {
              isVerified = !isVerified;
            });
          },
          onAlertPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Alert triggered!'),
              ),
            );
          },
        );
      },
    );
  }
}