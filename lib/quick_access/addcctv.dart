import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

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
              style: GoogleFonts.raleway(), // Apply Raleway font to TextField input
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
            onPressed: () async {
              if (_isValidRtspLink(rtspLink)) {
                // Show Terms and Conditions Dialog
                bool acceptedTerms = await showTermsAndConditionsDialog(context);
                if (acceptedTerms) {
                  // Send RTSP link to Firestore
                  await _sendRtspLinkToFirestore(context, rtspLink);
                  Navigator.of(context).pop(); // Close the dialog
                }
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

/// Function to show Terms and Conditions Dialog
Future<bool> showTermsAndConditionsDialog(BuildContext context) async {
  bool accepted = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'By adding this CCTV camera, you agree to the following terms:',
                style: GoogleFonts.raleway(),
              ),
              SizedBox(height: 10),
              Text(
                '1. Do not misuse the RTSP link.\n'
                '2. Ensure the link is secure and accessible only to authorized users.\n'
                '3. You are responsible for any misuse of the link.',
                style: GoogleFonts.raleway(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without accepting
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.raleway(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              accepted = true;
              Navigator.of(context).pop(); // Close the dialog and accept terms
            },
            child: Text(
              'Accept',
              style: GoogleFonts.raleway(),
            ),
          ),
        ],
      );
    },
  );
  return accepted;
}

/// Function to send RTSP link to Firestore
Future<void> _sendRtspLinkToFirestore(BuildContext context, String rtspLink) async {
  try {
    // Get Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Add RTSP link to the 'addCCTV' collection
    await firestore.collection('addCCTV').add({
      'rtspLink': rtspLink,
      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
    });

    // Show success message (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CCTV added successfully!')),
    );
  } catch (e) {
    // Handle errors
    print('Error adding RTSP link to Firestore: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add CCTV. Please try again.')),
    );
  }
}