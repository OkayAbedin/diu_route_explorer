import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  // Mock notifications data since we're removing external dependencies
  final List<dynamic> _mockNotifications = [
    {
      'id': '1',
      'title': 'Welcome to DIU Route Explorer',
      'message':
          'Stay updated with the latest bus schedules and route information.',
      'timestamp':
          DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
      'type': 'info',
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Route Update',
      'message':
          'New shuttle routes have been added to improve campus connectivity.',
      'timestamp': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'type': 'update',
      'isRead': false,
    },
  ];

  // Cache key for notifications
  final String _cacheKey = 'cached_notifications';

  // Get notifications from cache or use mock data
  Future<List<dynamic>> getNotifications({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      // Try to get from cache first
      final cachedData = await _getFromCache();
      if (cachedData != null) {
        return cachedData;
      }
    }

    try {
      // Use mock data instead of external API
      final notifications = List<dynamic>.from(_mockNotifications);

      // Cache the data
      await _cacheData(notifications);

      return notifications;
    } catch (e) {
      // If caching fails, still return mock data
      return List<dynamic>.from(_mockNotifications);
    }
  }

  // Cache notifications data
  Future<void> _cacheData(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(data);
      await prefs.setString(_cacheKey, jsonString);
      print('Notifications cached successfully');
    } catch (e) {
      print('Error caching notifications: $e');
    }
  }

  // Get cached notifications
  Future<List<dynamic>?> _getFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);

      if (jsonString != null) {
        final data = json.decode(jsonString);
        print('Loaded notifications from cache');
        return List<dynamic>.from(data);
      }
      return null;
    } catch (e) {
      print('Error loading notifications from cache: $e');
      return null;
    }
  }
}
