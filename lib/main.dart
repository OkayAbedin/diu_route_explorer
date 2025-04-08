import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/route_information_screen.dart';
import 'screens/bus_schedule_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';

void main() async {
  // Ensure Flutter is initialized before using platform plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isOnboardingCompleted = false;
  String? _userType;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final userType = await _authService.getUserType();
    final isOnboardingCompleted = await _authService.isOnboardingCompleted();
    final userId = await _authService.getUserId();

    setState(() {
      _isLoggedIn = isLoggedIn;
      _userType = userType;
      _isOnboardingCompleted = isOnboardingCompleted;
      _userId = userId;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIU Route Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _isLoading ? _buildLoadingScreen() : _getInitialScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/bus_schedule': (context) => BusScheduleScreen(),
        '/notifications': (context) => NotificationScreen(),
        '/route_information': (context) => RouteInformationScreen(),
        '/settings': (context) => SettingsScreen(),
        '/admin_dashboard': (context) => AdminDashboardScreen(),
        '/help_support': (context) => HelpSupportScreen(),
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 88, 13, 218),
        ),
      ),
    );
  }

  Widget _getInitialScreen() {
    if (_isLoggedIn) {
      // Check if onboarding is completed
      if (!_isOnboardingCompleted && _userId != null) {
        // Show onboarding screen for first-time users
        return OnboardingScreen(
          userId: _userId!,
          userType: _userType ?? AuthService.USER_TYPE_STUDENT,
        );
      } else {
        // Show appropriate screen based on user type
        if (_userType == AuthService.USER_TYPE_ADMIN) {
          return AdminDashboardScreen();
        } else {
          return BusScheduleScreen();
        }
      }
    } else {
      return LoginScreen();
    }
  }
}
