import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diu_route_explorer/services/notification_service.dart';

void main() {
  group('Notification Service Tests', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    test('should return empty list for mock notifications', () async {
      final notifications = await notificationService.getNotifications();
      expect(notifications, isEmpty);
    });

    test('should mark notification as read without error', () async {
      // This should not throw an error even with empty notifications
      await expectLater(notificationService.markAsRead('test-id'), completes);
    });

    test('should get unread count without error', () async {
      final count = await notificationService.getUnreadCount();
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('should clear all notifications without error', () async {
      await expectLater(notificationService.clearAll(), completes);
    });

    test('should subscribe to topic without error', () async {
      await expectLater(
        notificationService.subscribeToTopic('test_topic'),
        completes,
      );
    });

    test('should unsubscribe from topic without error', () async {
      await expectLater(
        notificationService.unsubscribeFromTopic('test_topic'),
        completes,
      );
    });
  });

  group('SnackBar Integration Tests', () {
    testWidgets('should show SnackBar when triggered', (
      WidgetTester tester,
    ) async {
      // Build a simple scaffold with a button that shows SnackBar
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test SnackBar'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text('Show SnackBar'),
                  ),
                ),
          ),
        ),
      );

      // Find and tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Verify SnackBar appears
      expect(find.text('Test SnackBar'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      // Test passes - SnackBar appears correctly
    });
  });
}
