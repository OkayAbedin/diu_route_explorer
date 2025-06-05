import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // You can add custom logic here for background message handling
}

class FCMNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Notification channel for Android - using generic configuration
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel', // id
    'Default Notifications', // title
    description: '',
    importance: Importance.high,
  );
  // Initialize FCM notification service
  static Future<void> initialize() async {
    // On web, skip most initialization but still set up basic Firebase Messaging
    if (kIsWeb) {
      await _initializeWebFirebaseMessaging();
      return;
    }

    // Request notification permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get and save FCM token
    await _getAndSaveToken(); // Set up message handlers
    _setupMessageHandlers();

    // Set background message handler (not supported on web)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Initialize Firebase Messaging for web (simplified)
  static Future<void> _initializeWebFirebaseMessaging() async {
    try {
      // Only request basic permission on web
      await _firebaseMessaging.requestPermission();
      print('Firebase Messaging initialized for web');
    } catch (e) {
      print('Firebase Messaging initialization failed on web: $e');
    }
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    // Skip platform-specific permissions on web
    if (kIsWeb) {
      await _firebaseMessaging.requestPermission();
      return;
    }

    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    // For Android 13+, request notification permission
    if (Platform.isAndroid) {
      await _firebaseMessaging.requestPermission();
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    // Skip local notifications initialization on web
    if (kIsWeb) {
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (!kIsWeb) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      // Handle notification tap - navigate to specific screen
      print('Notification tapped with payload: $payload');
      // You can parse the payload and navigate to specific screens
      _handleNotificationNavigation(payload);
    }
  }

  // Handle notification navigation
  static void _handleNotificationNavigation(String payload) {
    try {
      final data = json.decode(payload);
      final type = data['type'] ?? '';

      // Navigate based on notification type
      switch (type) {
        case 'route_update':
          // Navigate to route information screen
          break;
        case 'schedule_change':
          // Navigate to bus schedule screen
          break;
        case 'general':
        default:
          // Navigate to notification screen
          break;
      }
    } catch (e) {
      print('Error parsing notification payload: $e');
    }
  }

  // Get and save FCM token
  static Future<void> _getAndSaveToken() async {
    try {
      final String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _saveTokenToPreferences(token);
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // Save token to shared preferences
  static Future<void> _saveTokenToPreferences(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  // Save token to Firestore for targeting specific users
  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      // You can save token with user ID for targeted notifications
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId != null) {
        String platform = 'web';
        if (!kIsWeb) {
          platform = Platform.isIOS ? 'ios' : 'android';
        }

        await _firestore.collection('user_tokens').doc(userId).set({
          'token': token,
          'platform': platform,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving token to Firestore: $e');
    }
  }

  // Set up message handlers
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle message when app is launched from terminated state
    _handleInitialMessage();

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      print('FCM Token refreshed: $token');
      _saveTokenToPreferences(token);
      _saveTokenToFirestore(token);
    });
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');

    // Save notification to local storage
    await _saveNotificationLocally(message);

    // Show local notification
    await _showLocalNotification(message);
  }

  // Handle message when app is opened from notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message clicked: ${message.messageId}');
    _saveNotificationLocally(message);

    // Handle navigation based on message data
    if (message.data.isNotEmpty) {
      _handleNotificationNavigation(json.encode(message.data));
    }
  }

  // Handle initial message (app launched from terminated state)
  static Future<void> _handleInitialMessage() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('App launched from notification: ${initialMessage.messageId}');
      _saveNotificationLocally(initialMessage);

      // Handle navigation
      if (initialMessage.data.isNotEmpty) {
        _handleNotificationNavigation(json.encode(initialMessage.data));
      }
    }
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    // Skip local notifications on web - browser handles them
    if (kIsWeb) {
      return;
    }

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  // Save notification to local storage
  static Future<void> _saveNotificationLocally(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing notifications
      final existingNotificationsJson =
          prefs.getString('local_notifications') ?? '[]';
      final List<dynamic> existingNotifications = json.decode(
        existingNotificationsJson,
      ); // Create new notification object
      final newNotification = {
        'id':
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'title': message.notification?.title ?? '',
        'message': message.notification?.body ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'type': message.data['type'] ?? 'general',
        'isRead': false,
        'data': message.data,
      };

      // Add to existing notifications
      existingNotifications.insert(0, newNotification);

      // Keep only latest 50 notifications
      if (existingNotifications.length > 50) {
        existingNotifications.removeRange(50, existingNotifications.length);
      }

      // Save back to preferences
      await prefs.setString(
        'local_notifications',
        json.encode(existingNotifications),
      );
    } catch (e) {
      print('Error saving notification locally: $e');
    }
  }

  // Get all notifications from local storage
  static Future<List<dynamic>> getLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('local_notifications') ?? '[]';
      return json.decode(notificationsJson);
    } catch (e) {
      print('Error getting local notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('local_notifications') ?? '[]';
      final List<dynamic> notifications = json.decode(notificationsJson);

      // Find and update notification
      for (var notification in notifications) {
        if (notification['id'] == notificationId) {
          notification['isRead'] = true;
          break;
        }
      }

      // Save updated notifications
      await prefs.setString('local_notifications', json.encode(notifications));
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Get unread notification count
  static Future<int> getUnreadNotificationCount() async {
    try {
      final notifications = await getLocalNotifications();
      return notifications
          .where((notification) => !notification['isRead'])
          .length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_notifications', '[]');
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Subscribe to topic for receiving targeted notifications
  static Future<void> subscribeToTopic(String topic) async {
    // Skip subscription on web platform
    if (kIsWeb) {
      print('Topic subscription not available on web platform: $topic');
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    // Skip unsubscription on web platform
    if (kIsWeb) {
      print('Topic unsubscription not available on web platform: $topic');
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  // Get current FCM token
  static Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting current token: $e');
      return null;
    }
  }
}
