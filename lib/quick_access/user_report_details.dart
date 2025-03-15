import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert'; // For Base64 decoding

class UserReportsDetails extends StatefulWidget {
  final String image64; // Base64 image
  final String timestamp;
  final String location;
  final String animalName;
  final String description;
  final String emailId;
  final bool isVerified;
  final String documentId; // Add documentId parameter
  final Function() onVerifyPressed;
  final Function() onAlertPressed;

  const UserReportsDetails({
    Key? key,
    required this.image64,
    required this.timestamp,
    required this.location,
    required this.animalName,
    required this.description,
    required this.emailId,
    required this.isVerified,
    required this.documentId, // Add documentId parameter
    required this.onVerifyPressed,
    required this.onAlertPressed,
  }) : super(key: key);

  @override
  _UserReportsDetailsState createState() => _UserReportsDetailsState();
}

class _UserReportsDetailsState extends State<UserReportsDetails> {
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
            // Image (if Base64 image is available)
            if (widget.image64.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(widget.image64), // Decode Base64 image
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Failed to load image');
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Name
            Text(
              'Name: ${widget.animalName}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'Description: ${widget.description}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Email ID
            Text(
              'Email ID: ${widget.emailId}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

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
                  onTap: () async {
                    await widget.onAlertPressed(); // Call the parent's onAlertPressed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Alert Triggered'),
                      ),
                    );
                  },
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
}