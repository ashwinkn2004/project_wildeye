import 'package:flutter/material.dart';
import 'package:project_wildeye/screens/login.dart';
import 'package:project_wildeye/screens/signup.dart';
import 'package:project_wildeye/screens/success.dart';

class Routes {
  static const String signUp = '/signup';
  static const String login = '/login';
  static const String success = '/success';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      signUp: (BuildContext context) => SignUpScreen(),
      login: (BuildContext context) => LoginScreen(),
      success: (BuildContext context) => SuccessPage(),
    };
  }
}
