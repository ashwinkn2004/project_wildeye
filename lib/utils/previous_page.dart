import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _lastRouteKey = 'last_route';

  // Save the last opened route
  static Future<void> saveLastRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRouteKey, route);
  }

  // Get the last opened route
  static Future<String?> getLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRouteKey);
  }
}
