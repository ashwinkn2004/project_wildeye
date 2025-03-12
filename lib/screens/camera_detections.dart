import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:project_wildeye/quick_access/cam_detection_details.dart'; // Adjust import

class CameraDetectionsScreen extends StatefulWidget {
  @override
  State<CameraDetectionsScreen> createState() => _CameraDetectionsScreenState();
}

class _CameraDetectionsScreenState extends State<CameraDetectionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    initializeNotificationsAndMessaging();
    listenForNewDetections();
  }

  Future<void> initializeNotificationsAndMessaging() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.messageId}');
      showNotification(
        title: message.notification?.title ?? 'New Detection',
        body: message.notification?.body ?? 'A new detection has arrived.',
      );
      playAlertSound();
    });

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked from background: ${message.messageId}');
    });

    // Handle terminated state (app closed)
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state: ${initialMessage.messageId}');
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Background message received: ${message.messageId}');
    // Initialize FlutterLocalNotificationsPlugin in background
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Show notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'detection_channel',
      'Detections',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alert_sound'), // Add sound file to raw folder
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'New Detection',
      message.notification?.body ?? 'A new detection has arrived.',
      platformChannelSpecifics,
    );

    // Play sound in background (optional, requires additional setup)
    // Note: Playing sound in background may require platform-specific code
  }

  void listenForNewDetections() {
    _firestore
        .collection('detections')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty && mounted) {
        final latestDetection = snapshot.docs.first;
        final data = latestDetection.data() as Map<String, dynamic>;
        showNotification(
          title: 'New Detection',
          body: 'A new detection has arrived: ${data['label']}',
        );
        playAlertSound();
      }
    });
  }

  void showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'detection_channel',
      'Detections',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alert_sound'), // Sound file in res/raw
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'detection',
    );
  }

  void playAlertSound() async {
    await audioPlayer.play(AssetSource('alert_sound.mp3'));
    await Future.delayed(Duration(minutes: 1));
    await audioPlayer.stop();
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
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.raleway(fontSize: 18),
                ),
              );
            }
            final alerts = snapshot.data!.docs;
            return ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) => _buildAlertCard(alerts[index]),
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
    final String documentId = doc.id;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error_outline, color: Colors.red),
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
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  // Add delete functionality if needed
                },
              ),
              IconButton(
                icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                onPressed: () {
                  _showDetailsPopup(
                      context, imageUrl, videoUrl, formattedTime, location, documentId);
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
    final docSnapshot =
        await _firestore.collection('detections').doc(documentId).get();
    final bool isVerified = docSnapshot['verified'] ?? false;

    showDialog(
      context: context,
      builder: (context) => CamDetectionDetails(
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Alert triggered!')));
        },
        documentId: documentId,
      ),
    );
  }
}