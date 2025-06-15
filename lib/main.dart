import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/route_information_screen.dart';
import 'screens/bus_schedule_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/fcm_notification_service.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  // Ensure Flutter is initialized before using platform plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue app execution even if Firebase fails
  }

  // Initialize FCM notification service in background for mobile platforms
  if (!kIsWeb) {
    // Use a microtask to avoid blocking the main thread
    Future.microtask(() async {
      try {
        await FCMNotificationService.initialize();
      } catch (e) {
        if (kDebugMode) {
          print('FCM initialization error: $e');
        }
      }
    });
  }

  // Run the app immediately
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    // Start checking login state but don't block the UI
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    try {
      // Get all user data in a single call to reduce SharedPreferences overhead
      final userData = await _authService.getAllUserData();
      if (mounted) {
        setState(() {
          _isLoggedIn = userData['isLoggedIn'];
          _userType = userData['userType'];
          _isOnboardingCompleted = userData['isOnboardingCompleted'];
          _userId = userData['userId'];
          _isLoading = false; // This will trigger navigation from splash screen
        });
      }
    } catch (e) {
      print('Error checking login state: $e');
      // Fallback to safe defaults
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userType = null;
          _isOnboardingCompleted = false;
          _userId = null;
          _isLoading = false; // This will trigger navigation from splash screen
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIU Route Explorer',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home:
          _isLoading
              ? UnifiedSplashScreen(onLoadingComplete: _getInitialScreen)
              : _getInitialScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/bus_schedule': (context) => BusScheduleScreen(),
        '/notifications': (context) => NotificationScreen(),
        '/route_information': (context) => RouteInformationScreen(),
        '/settings': (context) => SettingsScreen(),
        '/help_support': (context) => HelpSupportScreen(),
      },
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
        // Show bus schedule screen for all users
        return BusScheduleScreen();
      }
    } else {
      return LoginScreen();
    }
  }
}
