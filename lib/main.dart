import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/route_information_screen.dart';
import 'screens/bus_schedule_screen.dart';
import 'screens/notification_screen.dart';

void main() async {
  // Ensure Flutter is initialized before using platform plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIU Route Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/bus_schedule': (context) => BusScheduleScreen(),
        '/notifications': (context) => NotificationScreen(),
        '/route_information': (context) => RouteInformationScreen(),
      },
    );
  }
}
