import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  // Empty notifications list - no hard-coded notifications
  final List<dynamic> _mockNotifications = [];

  // Cache key for notifications
  final String _cacheKey = 'cached_notifications';

  // Get notifications - combines FCM notifications with mock data
  Future<List<dynamic>> getNotifications({bool forceRefresh = false}) async {
    try {
      // Get FCM notifications from local storage
      final fcmNotifications = await _getLocalNotifications();

      if (fcmNotifications.isNotEmpty) {
        // If we have FCM notifications, return them
        await _cacheData(fcmNotifications);
        return fcmNotifications;
      }

      // Fallback to cached data or mock data
      if (!forceRefresh) {
        final cachedData = await _getFromCache();
        if (cachedData != null) {
          return cachedData;
        }
      }

      // Use mock data as fallback
      final notifications = List<dynamic>.from(_mockNotifications);
      await _cacheData(notifications);
      return notifications;
    } catch (e) {
      print('Error getting notifications: $e');
      // Return mock data as final fallback
      return List<dynamic>.from(_mockNotifications);
    }
  }

  // Get FCM notifications from local storage
  Future<List<dynamic>> _getLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('local_notifications') ?? '[]';
      return json.decode(notificationsJson);
    } catch (e) {
      print('Error getting local FCM notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _markNotificationAsRead(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark notification as read in local storage
  Future<void> _markNotificationAsRead(String notificationId) async {
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
  Future<int> getUnreadCount() async {
    try {
      final notifications = await _getLocalNotifications();
      return notifications
          .where((notification) => !notification['isRead'])
          .length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_notifications', '[]');
      // Also clear cache
      await prefs.remove(_cacheKey);
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Subscribe to notification topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      // This would typically call FCM subscribe method
      print('Subscribing to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from notification topics
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      // This would typically call FCM unsubscribe method
      print('Unsubscribing from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
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
