import 'package:Caption_Calling/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/login/login_page.dart';


class Routes {
  static const String home = '/home';
  static const String login = '/login';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(), // BasePage wraps HomePage
    login: (context) => LoginScreen(),
  };

  static Future<String> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn ? home : login;
  }
}
