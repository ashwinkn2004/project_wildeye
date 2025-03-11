import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class AlertNotification extends StatefulWidget {
  @override
  State<AlertNotification> createState() => _AlertNotificationState();
}

class _AlertNotificationState extends State<AlertNotification> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Content Row
        Row(
          children: [
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

        // Image and Video Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildButton(
                "Image",
                Icons.photo_library_outlined, // Changed icon to arrow
          
                Colors.white, // Text color
                Colors.green, // Background color
                () => _showImagePopup(context, imageUrl),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildButton(
                "Video",
                Icons.video_collection_rounded, // Changed icon to arrow
                Colors.white, // Text color
                Colors.blue, // Background color
                () => _showVideoPopup(context, videoUrl),
              ),
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



  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                imageUrl,
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

  void _showVideoPopup(BuildContext context, String videoUrl) {
    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No video available', style: GoogleFonts.raleway()),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 200,
            width: 300,
            child: VideoPlayerWidget(videoUrl: videoUrl),
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

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
