import 'package:flutter/material.dart';
import 'package:project_wildeye/quick_access/emergency_help.dart';
import 'package:project_wildeye/screens/admin.dart';
import 'package:project_wildeye/screens/alert_notification.dart';
import 'package:project_wildeye/screens/camera_detections.dart';
import 'package:project_wildeye/screens/client.dart';
import 'package:project_wildeye/screens/login.dart';
import 'package:project_wildeye/screens/profile.dart';
import 'package:project_wildeye/screens/report.dart';
import 'package:project_wildeye/screens/signup.dart';
import 'package:project_wildeye/screens/user_reports.dart';

class Routes {
  static const String signUp = '/signup';
  static const String login = '/login';
  static const String client = '/client';
  static const String emergencyHelp = '/emergencyHelp';
  static const String profile = '/profile';
  static const String report = '/report';
  static const String alertNotification = '/alertNotification';
  static const String admin = '/admin';
  static const String cameraDetections = '/cameraDetections';
  static const String userReports = '/userReports';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      signUp: (BuildContext context) => SignUpScreen(),
      login: (BuildContext context) => LoginScreen(),
      client: (BuildContext context) => ClientScreen(),
      emergencyHelp: (BuildContext context) => EmergencyHelp(),
      profile: (BuildContext context) => ProfileScreen(),
      report: (BuildContext context) => ReportScreen(),
      alertNotification: (BuildContext context) => AlertNotification(),
      admin: (BuildContext context) => AdminScreen(),
      cameraDetections: (BuildContext context) => CameraDetectionsScreen(),
      userReports: (BuildContext context) => UserReportsScreen(),
    };
  }
}
