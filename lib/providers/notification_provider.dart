import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<dynamic> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Initialize notification provider
  Future<void> initialize() async {
    await loadNotifications();
    await _updateUnreadCount();

    // Subscribe to default topics
    await _subscribeToDefaultTopics();
  }

  // Load notifications
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(
        forceRefresh: forceRefresh,
      );
      await _updateUnreadCount();
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        await _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    try {
      await _notificationService.clearAll();
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Subscribe to notification topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from notification topics
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Subscribe to default topics based on user preferences
  Future<void> _subscribeToDefaultTopics() async {
    try {
      // Removed hard-coded topic subscriptions
      // Topics should be managed dynamically based on user preferences
    } catch (e) {
      print('Error subscribing to default topics: $e');
    }
  }

  // Update unread count
  Future<void> _updateUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
    } catch (e) {
      print('Error updating unread count: $e');
      _unreadCount = 0;
    }
  }

  // Refresh notifications
  Future<void> refresh() async {
    await loadNotifications(forceRefresh: true);
  }

  // Get notifications by type
  List<dynamic> getNotificationsByType(String type) {
    return _notifications
        .where((notification) => notification['type'] == type)
        .toList();
  }

  // Get unread notifications
  List<dynamic> getUnreadNotifications() {
    return _notifications
        .where((notification) => !notification['isRead'])
        .toList();
  }
}
