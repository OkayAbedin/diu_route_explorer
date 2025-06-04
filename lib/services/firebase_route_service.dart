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
          await _firestore
              .collection(_routesCollection)
              .orderBy('Route')
              .orderBy('Time')
              .get();

      final List<Map<String, dynamic>> routes =
          querySnapshot.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList();

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
        .orderBy('Time')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
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
}
