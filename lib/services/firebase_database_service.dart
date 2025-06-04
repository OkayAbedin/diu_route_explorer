import 'firebase_route_service.dart';

class FirebaseDatabaseService {
  final FirebaseRouteService _routeService = FirebaseRouteService();

  // Test Firebase connection
  Future<bool> testConnection() async {
    try {
      print('Testing Firebase connection...');

      // Try to get routes which will test the connection
      final routes = await _routeService.getRoutes();

      print('Firebase connection successful - found ${routes.length} routes');
      return true;
    } catch (e) {
      print('Firebase connection failed: $e');
      return false;
    }
  }

  // Get current database (routes)
  Future<List<Map<String, dynamic>>> getDatabase() async {
    return await _routeService.getRoutes();
  }

  // Update entire database (batch operation)
  Future<bool> updateDatabase(List<Map<String, dynamic>> newData) async {
    try {
      print('Updating database with ${newData.length} routes');

      // Clear existing routes
      await _routeService.clearAllRoutes();

      // Upload new routes
      final bool success = await _routeService.batchUploadRoutes(newData);

      if (success) {
        print('Database updated successfully');
        return true;
      } else {
        print('Database update failed');
        return false;
      }
    } catch (e) {
      print('Error updating database: $e');
      return false;
    }
  }

  // Add single route
  Future<bool> addRoute(Map<String, dynamic> routeData) async {
    return await _routeService.addRoute(routeData);
  }

  // Update single route
  Future<bool> updateRoute(
    String routeId,
    Map<String, dynamic> routeData,
  ) async {
    return await _routeService.updateRoute(routeId, routeData);
  }

  // Delete single route
  Future<bool> deleteRoute(String routeId) async {
    return await _routeService.deleteRoute(routeId);
  }

  // Get routes as stream for real-time updates
  Stream<List<Map<String, dynamic>>> getDatabaseStream() {
    return _routeService.getRoutesStream();
  }

  // Migrate data from JSONBin to Firebase
  Future<bool> migrateFromJsonBin(
    List<Map<String, dynamic>> jsonBinData,
  ) async {
    try {
      print('Starting migration from JSONBin to Firebase...');
      print('Data contains ${jsonBinData.length} routes');

      // Validate data structure
      if (jsonBinData.isEmpty) {
        print('No data to migrate');
        return true;
      }

      // Clear existing data (optional - remove if you want to keep existing data)
      // await _routeService.clearAllRoutes();

      // Upload all routes to Firebase
      final bool success = await _routeService.batchUploadRoutes(jsonBinData);

      if (success) {
        print('Migration completed successfully!');
        return true;
      } else {
        print('Migration failed');
        return false;
      }
    } catch (e) {
      print('Error during migration: $e');
      return false;
    }
  }

  // Backup current Firebase data
  Future<List<Map<String, dynamic>>> backupDatabase() async {
    try {
      final routes = await _routeService.getRoutes();
      print('Backup created with ${routes.length} routes');
      return routes;
    } catch (e) {
      print('Error creating backup: $e');
      return [];
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final routes = await _routeService.getRoutes();
      final routeGroups = <String, int>{};
      final scheduleTypes = <String, int>{};

      for (final route in routes) {
        final routeNumber = route['Route'] as String? ?? 'Unknown';
        final schedule = route['Schedule'] as String? ?? 'Unknown';

        routeGroups[routeNumber] = (routeGroups[routeNumber] ?? 0) + 1;
        scheduleTypes[schedule] = (scheduleTypes[schedule] ?? 0) + 1;
      }

      return {
        'totalRoutes': routes.length,
        'routeGroups': routeGroups,
        'scheduleTypes': scheduleTypes,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting database stats: $e');
      return {
        'totalRoutes': 0,
        'routeGroups': {},
        'scheduleTypes': {},
        'error': e.toString(),
      };
    }
  }
}
