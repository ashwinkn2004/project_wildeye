import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final AudioPlayer audioPlayer = AudioPlayer();

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");

  // Show local notification
  showNotification(
    title: message.notification?.title ?? 'New Detection',
    body: message.notification?.body ?? 'A new detection has arrived.',
  );

  // Play alert sound in the background
  await AndroidAlarmManager.oneShot(
    Duration(seconds: 1), // Start immediately
    1, // Unique ID for the alarm
    playAlertSoundInBackground,
  );
}

// Function to play alert sound in the background
void playAlertSoundInBackground() async {
  await audioPlayer.play(AssetSource('alert_sound.mp3')); // Add your alert sound file to assets
  await Future.delayed(Duration(minutes: 1)); // Play sound for 1 minute
  await audioPlayer.stop();
}

void initializeFirebaseMessaging() async {
  await Firebase.initializeApp();

  // Request permission for notifications
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Configure Firebase Messaging
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    // Show local notification
    showNotification(
      title: message.notification?.title ?? 'New Detection',
      body: message.notification?.body ?? 'A new detection has arrived.',
    );

    // Play alert sound
    playAlertSound();
  });

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void showNotification({required String title, required String body}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
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

void playAlertSound() async {
  await audioPlayer.play(AssetSource('alert_sound.mp3')); // Add your alert sound file to assets
  await Future.delayed(Duration(minutes: 1)); // Play sound for 1 minute
  await audioPlayer.stop();
}

void initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}