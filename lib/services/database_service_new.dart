import 'firebase_database_service.dart';

class DatabaseService {
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();

  // Get current database
  Future<List<Map<String, dynamic>>> getDatabase() async {
    return await _firebaseDb.getDatabase();
  }

  // Update database
  Future<bool> updateDatabase(List<Map<String, dynamic>> newData) async {
    try {
      print('Updating database with data length: ${newData.length}');

      final bool success = await _firebaseDb.updateDatabase(newData);

      if (success) {
        print('Database updated successfully in Firebase');
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
    return await _firebaseDb.addRoute(routeData);
  }

  // Update single route - now takes routeId instead of index
  Future<bool> updateRoute(
    String routeId,
    Map<String, dynamic> routeData,
  ) async {
    return await _firebaseDb.updateRoute(routeId, routeData);
  }

  // Legacy update route method for backward compatibility
  Future<bool> updateRouteByIndex(
    int index,
    Map<String, dynamic> updatedRoute,
  ) async {
    try {
      final database = await getDatabase();
      print('Database size: ${database.length}, Updating index: $index');

      if (index >= 0 && index < database.length) {
        final routeId = database[index]['id'];
        if (routeId != null) {
          return await updateRoute(routeId, updatedRoute);
        }
      }
      print('Invalid index: $index for database of size ${database.length}');
      return false;
    } catch (e) {
      print('Error updating route by index: $e');
      return false;
    }
  }

  // Delete single route
  Future<bool> deleteRoute(String routeId) async {
    return await _firebaseDb.deleteRoute(routeId);
  }

  // Legacy delete route method for backward compatibility
  Future<bool> deleteRouteByIndex(int index) async {
    try {
      final database = await getDatabase();
      if (index >= 0 && index < database.length) {
        final routeId = database[index]['id'];
        if (routeId != null) {
          return await deleteRoute(routeId);
        }
      }
      return false;
    } catch (e) {
      print('Error deleting route by index: $e');
      return false;
    }
  }

  // Get database as stream for real-time updates
  Stream<List<Map<String, dynamic>>> getDatabaseStream() {
    return _firebaseDb.getDatabaseStream();
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    return await _firebaseDb.getDatabaseStats();
  }

  // Backup database
  Future<List<Map<String, dynamic>>> backupDatabase() async {
    return await _firebaseDb.backupDatabase();
  }
}
