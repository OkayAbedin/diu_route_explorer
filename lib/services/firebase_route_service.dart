import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _routesCollection = 'routes';
  // Get all routes from Firestore
  Future<List<Map<String, dynamic>>> getRoutes({
    bool forceRefresh = false,
  }) async {
    try {
      print('Fetching routes from Firestore...');

      final QuerySnapshot querySnapshot =
          await _firestore.collection(_routesCollection).orderBy('Route').get();

      final List<Map<String, dynamic>> routes =
          querySnapshot.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList();

      // Sort routes by time chronologically after fetching
      routes.sort((a, b) {
        // First sort by Route
        int routeComparison = _compareRoutes(
          a['Route'] ?? '',
          b['Route'] ?? '',
        );
        if (routeComparison != 0) return routeComparison;

        // Then sort by Time chronologically
        return _compareTimeStrings(a['Time'] ?? '', b['Time'] ?? '');
      });

      print('Successfully loaded ${routes.length} routes from Firestore');
      return routes;
    } catch (e) {
      print('Error fetching routes from Firestore: $e');
      // Return empty list on error
      return [];
    }
  }

  // Get routes as a stream for real-time updates
  Stream<List<Map<String, dynamic>>> getRoutesStream() {
    return _firestore
        .collection(_routesCollection)
        .orderBy('Route')
        .snapshots()
        .map((snapshot) {
          final routes =
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList();

          // Sort routes by time chronologically after fetching
          routes.sort((a, b) {
            // First sort by Route
            int routeComparison = _compareRoutes(
              a['Route'] ?? '',
              b['Route'] ?? '',
            );
            if (routeComparison != 0) return routeComparison;

            // Then sort by Time chronologically
            return _compareTimeStrings(a['Time'] ?? '', b['Time'] ?? '');
          });

          return routes;
        });
  }

  // Add a new route
  Future<bool> addRoute(Map<String, dynamic> routeData) async {
    try {
      // Remove id if it exists (Firestore will auto-generate)
      routeData.remove('id');

      await _firestore.collection(_routesCollection).add(routeData);
      print('Route added successfully');
      return true;
    } catch (e) {
      print('Error adding route: $e');
      return false;
    }
  }

  // Update an existing route
  Future<bool> updateRoute(
    String routeId,
    Map<String, dynamic> routeData,
  ) async {
    try {
      // Remove id from data
      routeData.remove('id');

      await _firestore
          .collection(_routesCollection)
          .doc(routeId)
          .update(routeData);
      print('Route updated successfully');
      return true;
    } catch (e) {
      print('Error updating route: $e');
      return false;
    }
  }

  // Delete a route
  Future<bool> deleteRoute(String routeId) async {
    try {
      await _firestore.collection(_routesCollection).doc(routeId).delete();
      print('Route deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting route: $e');
      return false;
    }
  }

  // Batch upload routes (useful for initial migration)
  Future<bool> batchUploadRoutes(List<Map<String, dynamic>> routes) async {
    try {
      final WriteBatch batch = _firestore.batch();

      for (final route in routes) {
        // Remove id if it exists
        final routeData = Map<String, dynamic>.from(route);
        routeData.remove('id');

        final docRef = _firestore.collection(_routesCollection).doc();
        batch.set(docRef, routeData);
      }

      await batch.commit();
      print('Batch upload completed successfully: ${routes.length} routes');
      return true;
    } catch (e) {
      print('Error in batch upload: $e');
      return false;
    }
  }

  // Clear all routes (useful for testing)
  Future<bool> clearAllRoutes() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(_routesCollection).get();
      final WriteBatch batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('All routes cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing routes: $e');
      return false;
    }
  }

  // Helper method to compare route codes (R1, R2, F1, etc.)
  int _compareRoutes(String routeA, String routeB) {
    // Extract prefix and number from route codes
    String prefixA = routeA.replaceAll(RegExp(r'\d+'), '');
    String prefixB = routeB.replaceAll(RegExp(r'\d+'), '');

    int? numberA = int.tryParse(routeA.replaceAll(RegExp(r'[^0-9]'), ''));
    int? numberB = int.tryParse(routeB.replaceAll(RegExp(r'[^0-9]'), ''));

    numberA ??= 0;
    numberB ??= 0;

    // First sort by prefix (R comes before F)
    const Map<String, int> prefixOrder = {'R': 1, 'F': 2};
    int orderA = prefixOrder[prefixA] ?? 999;
    int orderB = prefixOrder[prefixB] ?? 999;

    if (orderA != orderB) {
      return orderA.compareTo(orderB);
    }

    // If same prefix, sort by number
    return numberA.compareTo(numberB);
  }

  // Helper method to compare time strings chronologically
  int _compareTimeStrings(String timeA, String timeB) {
    try {
      DateTime parsedTimeA = _parseTimeString(timeA);
      DateTime parsedTimeB = _parseTimeString(timeB);
      return parsedTimeA.compareTo(parsedTimeB);
    } catch (e) {
      // If parsing fails, fall back to string comparison
      return timeA.compareTo(timeB);
    }
  }

  // Helper method to parse time strings like "7:00 AM", "10:00 AM", "2:30 PM"
  DateTime _parseTimeString(String timeString) {
    // Remove extra spaces and convert to uppercase
    String cleanTime = timeString.trim().toUpperCase();

    // Split into time part and AM/PM part
    List<String> parts = cleanTime.split(' ');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }

    String timePart = parts[0];
    String amPm = parts[1];

    // Split time into hours and minutes
    List<String> timeParts = timePart.split(':');
    if (timeParts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    // Convert to 24-hour format
    if (amPm == 'PM' && hour != 12) {
      hour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      hour = 0;
    }

    // Return DateTime with today's date but the parsed time
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
