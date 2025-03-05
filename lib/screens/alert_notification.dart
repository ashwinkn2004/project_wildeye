import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
      margin: EdgeInsets.only(bottom: 18), // Should be 'bottom'
      decoration: BoxDecoration(
        color: Color(0xFFFDF9F3),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(0xFFE3F2E8),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
                bottom: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://via.placeholder.com/80',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.raleway(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Color(0xFF555555),
                      ),
                    ),
                    Text(
                      location,
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: Color(0xFFFDF9F3),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildButton(
                    "Image",
                    Icons.arrow_forward,
                    Color(0xFF0D47A1),
                    Color(0xFFDCE5F5),
                    () => _showImagePopup(context, imageUrl),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildButton(
                    "Video",
                    Icons.arrow_forward,
                    Color(0xFFC62828),
                    Color(0xFFF9DADA),
                    () => _showVideoPopup(context, videoUrl),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Color textColor, Color bgColor, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
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

    print('Opening video popup with URL: $videoUrl');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 200, // Match original UI height
            width: 300, // Match original UI width
            child: VideoWebView(videoUrl: videoUrl),
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

class VideoWebView extends StatefulWidget {
  final String videoUrl;

  const VideoWebView({required this.videoUrl});

  @override
  _VideoWebViewState createState() => _VideoWebViewState();
}

class _VideoWebViewState extends State<VideoWebView> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('Loading WebView with URL: ${widget.videoUrl}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(widget.videoUrl))
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (url) {
                  print('WebView started loading: $url');
                },
                onPageFinished: (url) {
                  print('WebView finished loading: $url');
                  setState(() {
                    _isLoading = false;
                  });
                },
                onWebResourceError: (error) {
                  print('WebView error: ${error.description}');
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            ),
        ),
        if (_isLoading)
          Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

