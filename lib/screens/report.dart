import 'dart:io';
import 'dart:convert'; // For Base64 encoding
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting user email
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  File? _selectedImage;
  final TextEditingController _animalController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _currentLocation;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to pick image: $e",
            style: GoogleFonts.raleway(),
          ),
        ),
      );
    }
  }

  // Function to detect current location
  Future<void> _detectLocation() async {
    try {
      print("Initializing permission check...");
      LocationPermission initialCheck = await Geolocator.checkPermission();
      print("Preliminary permission status: $initialCheck");

      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("Location services enabled: $serviceEnabled");
      if (!serviceEnabled) {
        setState(() {
          _currentLocation =
              "Location services are disabled. Please enable them in settings.";
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      print("Initial permission status: $permission");
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print("Permission after request: $permission");
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation =
                "Location permission denied. Please grant permission.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation =
              "Location permissions are permanently denied. Please enable them in app settings.";
        });
        await Geolocator.openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("Position fetched: ${position.latitude}, ${position.longitude}");
      setState(() {
        _currentLocation =
            "Lat: ${position.latitude}, Lng: ${position.longitude}";
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        _currentLocation = "Failed to fetch location: $e";
      });
    }
  }

  // Function to convert image to Base64
  String _imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Function to submit report to Firestore
  Future<void> _submitReport() async {
    try {
      if (_selectedImage == null ||
          _animalController.text.isEmpty ||
          _currentLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please fill all required fields.",
              style: GoogleFonts.raleway(),
            ),
          ),
        );
        return;
      }

      // Get the current user's email
      final User? user = _auth.currentUser;
      final String emailId = user?.email ?? "unknown@example.com";

      // Convert image to Base64
      final String image64 = _imageToBase64(_selectedImage!);

      // Prepare data for Firestore
      final Map<String, dynamic> reportData = {
        "adminReply": false,
        "animalName": _animalController.text,
        "description": _descriptionController.text,
        "emailId": emailId,
        "image64": image64,
        "location": _currentLocation,
        "verified": false,
      };

      // Add data to Firestore
      await _firestore.collection("userReport").add(reportData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Report submitted successfully!",
            style: GoogleFonts.raleway(),
          ),
        ),
      );

      // Clear form after submission
      setState(() {
        _selectedImage = null;
        _animalController.clear();
        _descriptionController.clear();
        _currentLocation = null;
      });
    } catch (e) {
      print("Error submitting report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to submit report. Please try again.",
            style: GoogleFonts.raleway(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Report',
          style: GoogleFonts.raleway(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Report wild animal activity outside the forest to help ensure safety and conservation efforts.",
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomPaint(
                    painter: DottedBorderPainter(color: Colors.black54),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              "Tap to Add Photo",
                              style: GoogleFonts.raleway(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Animal Name / Type",
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _animalController,
                decoration: InputDecoration(
                  hintText: "Enter animal name/type",
                  hintStyle: GoogleFonts.raleway(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Location",
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _detectLocation,
                  icon: const Icon(Icons.location_searching_outlined),
                  label: const Text(
                    "Get Current Location",
                    style: TextStyle(fontFamily: 'Raleway'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    iconColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_currentLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _currentLocation!,
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                "Description",
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Describe what you observed",
                  hintStyle: GoogleFonts.raleway(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Submit Report",
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// Custom painter for dotted border with rounded corners
class DottedBorderPainter extends CustomPainter {
  final Color color;

  DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 3;
    const double radius = 20; // Match container's borderRadius

    // Draw dotted rounded rectangle
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _createDashedPath(path, dashWidth, dashSpace);

    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final Path dashedPath = Path();
    final List<double> lengths = [];
    double distance = 0.0;
    bool draw = true;

    for (PathMetric metric in source.computeMetrics()) {
      while (distance < metric.length) {
        if (draw) {
          lengths.add(dashWidth);
        } else {
          lengths.add(dashSpace);
        }
        distance += lengths.last;
        draw = !draw;
      }
      distance = 0.0;
      draw = true;

      double drawn = 0.0;
      while (drawn < metric.length) {
        final double length = lengths.removeAt(0);
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(drawn, drawn + length),
            Offset.zero,
          );
        }
        drawn += length;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}