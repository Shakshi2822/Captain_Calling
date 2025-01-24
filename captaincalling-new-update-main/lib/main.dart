import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if the user is logged in
  final bool isLoggedIn = await checkLoginStatus();

  // Determine the initial route
  final String initialRoute = isLoggedIn ? '/home' : '/login';

  runApp(MyApp(initialRoute: initialRoute));
}

Future<bool> checkLoginStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getString('userId') != null ? true : false;
    debugPrint('Login state retrieved: $isLoggedIn');
    return isLoggedIn;
  } catch (e) {
    debugPrint('Error checking login status: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caption Calling',
      theme: ThemeData(primarySwatch: Colors.brown),
      initialRoute: initialRoute,
      routes: Routes.routes, // Define routes in route.dart
    );
  }
}
