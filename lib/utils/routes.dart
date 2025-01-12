import 'package:flutter/material.dart';
import 'package:project_wildeye/screens/login.dart';
import 'package:project_wildeye/screens/signup.dart';

class Routes {
  static const String signUp = '/signup';
  static const String login = '/login';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      signUp: (BuildContext context) => SignUpScreen(),
      login: (BuildContext context) => LoginScreen(),
    };
  }
}
