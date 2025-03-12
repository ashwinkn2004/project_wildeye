import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:project_wildeye/quick_access/cam_detection_details.dart';
import 'package:project_wildeye/quick_access/mobile_notifications.dart';

class CameraDetectionsScreen extends StatefulWidget {
  @override
  State<CameraDetectionsScreen> createState() => _CameraDetectionsScreenState();
}

class _CameraDetectionsScreenState extends State<CameraDetectionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MobileNotifications _mobileNotifications = MobileNotifications();

  @override
  void initState() {
    super.initState();
    _mobileNotifications.initialize();
    listenForNewDetections();
  }

  void listenForNewDetections() {
    _firestore
        .collection('detections')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      print("New detection received: ${snapshot.docs.length}");
      if (snapshot.docs.isNotEmpty) {
        final latestDetection = snapshot.docs.first;
        final data = latestDetection.data() as Map<String, dynamic>;
        final String animalName = data['label'] ?? 'Unknown Animal';

        print("Animal Name: $animalName");

        // Send notification with animal name
        _mobileNotifications.handleNotification(
          RemoteMessage(
            notification: RemoteNotification(
              title: 'New Detection: $animalName',
              body: 'A new detection has arrived.',
            ),
            data: {
              'animalName': animalName,
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Camera Detections",
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
    final String imageUrl =
        data['image_url'] ?? 'https://via.placeholder.com/80';
    final String videoUrl = data['video_url'] ?? '';
    final String documentId = doc.id; // Get the document ID

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
                  _showDetailsPopup(context, imageUrl, videoUrl, formattedTime,
                      location, documentId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetailsPopup(BuildContext context, String imageUrl, String videoUrl,
      String timestamp, String location, String documentId) async {
    // Fetch the latest isVerified value from Firestore
    final docSnapshot =
        await _firestore.collection('detections').doc(documentId).get();
    final bool isVerified = docSnapshot['verified'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return CamDetectionDetails(
          imageUrl: imageUrl,
          videoUrl: videoUrl,
          timestamp: timestamp,
          location: location,
          isVerified: isVerified,
          onVerifyPressed: () async {
            await _firestore.collection('detections').doc(documentId).update({
              'verified': true,
            });
          },
          onAlertPressed: () async {
            await _firestore.collection('detections').doc(documentId).update({
              'adminReply': true,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Alert triggered!'),
              ),
            );
          },
          documentId: documentId,
        );
      },
    );
  }
}