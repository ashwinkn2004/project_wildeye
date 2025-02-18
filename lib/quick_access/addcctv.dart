import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

void AddCctvCamera(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String rtspLink = '';
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Add CCTV Camera',
          style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                rtspLink = value;
              },
              decoration: InputDecoration(
                labelText: 'Enter RTSP Link',
                labelStyle: GoogleFonts.raleway(),
                border: OutlineInputBorder(),
              ),
              style: GoogleFonts
                  .raleway(), // Apply Raleway font to TextField input
            ),
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.raleway(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_isValidRtspLink(rtspLink)) {
                // Handle the RTSP link submission logic here
                Navigator.of(context).pop();
              } else {
                // Show an error if the RTSP link is invalid
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid RTSP link')),
                );
              }
            },
            child: Text(
              'Add',
              style: GoogleFonts.raleway(),
            ),
          ),
        ],
      );
    },
  );
}

/// Function to validate the RTSP link format
bool _isValidRtspLink(String link) {
  final RegExp rtspRegex = RegExp(
    r'^(rtsp):\/\/[^\s\/$.?#].[^\s]*$', // Checks for 'rtsp://' followed by a valid domain/URL
    caseSensitive: false,
  );
  return rtspRegex.hasMatch(link);
}
