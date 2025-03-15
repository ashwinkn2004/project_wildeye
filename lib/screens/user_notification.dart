import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // For Base64 decoding

class UserNotificationScreen extends StatefulWidget {
  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User Notifications",
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
              .collection('userReport')
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
                  'Error fetching notifications: ${snapshot.error}',
                  style: GoogleFonts.raleway(fontSize: 18),
                ),
              );
            }

            final alerts = snapshot.data!.docs;

            // Check if there are any notifications with adminReply true
            final hasAdminReplies = alerts.any((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['adminReply'] ?? false;
            });

            if (!hasAdminReplies) {
              return Center(
                child: Text(
                  'No detections found.',
                  style: GoogleFonts.raleway(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final doc = alerts[index];
                final data = doc.data() as Map<String, dynamic>;
                final bool adminReply = data['adminReply'] ?? false;

                // Only display the card if adminReply is true
                if (adminReply) {
                  return _buildAlertCard(doc);
                } else {
                  return Container(); // Return an empty container if adminReply is false
                }
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

    final String label = data['animalName'] ?? 'Unknown';
    final String? timestamp = data['timestamp'];
    final String location = data['location'] ?? 'Unknown';
    final String image64 = data['image64'] ?? ''; // Base64 image

    String formattedTime = 'N/A';
    if (timestamp != null) {
      try {
        // Parse the timestamp as a DateTime object
        final DateTime dateTime = DateTime.parse(timestamp);
        // Format the DateTime object to a readable string
        formattedTime = DateFormat('HH:mm dd/MM/yy').format(dateTime);
      } catch (e) {
        formattedTime = timestamp; // Fallback to the original timestamp if parsing fails
      }
    }

    // Decode Base64 image
    Widget imageWidget = image64.isNotEmpty
        ? Image.memory(
            base64Decode(image64),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error_outline, color: Colors.red);
            },
          )
        : const Icon(Icons.error_outline, color: Colors.red);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Content Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageWidget,
              ),
              const SizedBox(width: 16),
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
            ],
          ),

          // Divider
          const Divider(
            thickness: 1,
            color: Colors.grey,
            height: 24,
          ),

          // Image Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                "View Image",
                Icons.photo_library_outlined, // Changed icon to arrow
                Colors.white, // Text color
                Colors.green, // Background color
                () => _showImagePopup(context, image64),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Color textColor, Color bgColor, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor, // Background color
        foregroundColor: textColor, // Text and icon color
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: textColor),
      label: Text(
        text,
        style: GoogleFonts.raleway(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showImagePopup(BuildContext context, String image64) {
    if (image64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No image available', style: GoogleFonts.raleway()),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(
                base64Decode(image64),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Text('Failed to load image');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: GoogleFonts.raleway()),
            ),
          ],
        );
      },
    );
  }
}