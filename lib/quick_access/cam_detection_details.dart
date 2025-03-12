import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class CamDetectionDetails extends StatefulWidget {
  final String imageUrl;
  final String videoUrl;
  final String timestamp;
  final String location;
  final bool isVerified;
  final Function() onVerifyPressed;
  final Function() onAlertPressed;
  final String documentId;

  const CamDetectionDetails({
    Key? key,
    required this.imageUrl,
    required this.videoUrl,
    required this.timestamp,
    required this.location,
    required this.isVerified,
    required this.onVerifyPressed,
    required this.onAlertPressed,
    required this.documentId,
  }) : super(key: key);

  @override
  _CamDetectionDetailsState createState() => _CamDetectionDetailsState();
}

class _CamDetectionDetailsState extends State<CamDetectionDetails> {
  late bool _isVerified;

  @override
  void initState() {
    super.initState();
    _isVerified = widget.isVerified; // Initialize with the passed value
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (widget.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Failed to load image');
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Video Container (if video is available)
            if (widget.videoUrl.isNotEmpty)
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Open video player
                    _showVideoPopup(context, widget.videoUrl);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Play Video',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Timestamp
            Text(
              'Timestamp: ${widget.timestamp}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Location
            Text(
              'Location: ${widget.location}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Verified Status
            Row(
              children: [
                Text(
                  'Verified: ',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  _isVerified ? Icons.check_circle : Icons.cancel,
                  color: _isVerified ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Verify and Alert Containers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Verify Container
                GestureDetector(
                  onTap: () async {
                    await widget.onVerifyPressed(); // Call the parent's onVerifyPressed
                    setState(() {
                      _isVerified = true; // Update the local state
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Verify',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Alert Container
                GestureDetector(
                  onTap: widget.onAlertPressed,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Alert',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: GoogleFonts.raleway()),
        ),
      ],
    );
  }

  void _showVideoPopup(BuildContext context, String videoUrl) {
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

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
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