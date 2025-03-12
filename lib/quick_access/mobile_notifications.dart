import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class MobileNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      handleNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");

    // Initialize local notifications and audio player
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final AudioPlayer audioPlayer = AudioPlayer();

    // Extract animal name from message data
    final String animalName = message.data['animalName'] ?? 'Unknown Animal';

    // Show notification with animal name
    await _showNotification(
      flutterLocalNotificationsPlugin,
      title: 'New Detection: $animalName',
      body: message.notification?.body ?? 'A new detection has arrived.',
    );

    // Play alert sound
    await audioPlayer.play(AssetSource('assets/alert_sound.mp3'));
    await Future.delayed(Duration(minutes: 1)); // Play sound for 1 minute
    await audioPlayer.stop();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, {
    required String title,
    required String body,
  }) async {
    print("Showing notification: $title");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'your_channel_name', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      sound: RawResourceAndroidNotificationSound('alert_sound'), // Add sound
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void handleNotification(RemoteMessage message) {
    print("Handling notification: ${message.notification?.title}");

    // Extract animal name from message data
    final String animalName = message.data['animalName'] ?? 'Unknown Animal';

    // Show notification with animal name
    _showNotification(
      flutterLocalNotificationsPlugin,
      title: 'New Detection: $animalName',
      body: message.notification?.body ?? 'A new detection has arrived.',
    );

    // Play alert sound
    playAlertSound();
  }

  Future<void> playAlertSound() async {
    print("Playing alert sound");
    try {
      await audioPlayer.play(AssetSource('assets/alert_sound.mp3'));
      await Future.delayed(Duration(minutes: 1)); // Play sound for 1 minute
      await audioPlayer.stop();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }
}