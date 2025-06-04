import 'dart:convert';
import 'package:flutter/services.dart';
import 'firebase_route_service.dart';

class RouteService {
  final FirebaseRouteService _firebaseRouteService = FirebaseRouteService();

  // Get routes from Firebase (with fallback to local)
  Future<List<Map<String, dynamic>>> getRoutes({
    bool forceRefresh = false,
  }) async {
    try {
      print('Fetching routes from Firebase...');

      // Try to fetch from Firebase first
      final routes = await _firebaseRouteService.getRoutes(
        forceRefresh: forceRefresh,
      );

      if (routes.isNotEmpty) {
        print('Successfully loaded ${routes.length} routes from Firebase');
        return routes;
      } else {
        print('No routes found in Firebase, falling back to local data');
        return await _getLocalRoutes();
      }
    } catch (e) {
      print('Error fetching routes from Firebase: $e');
      print('Falling back to local routes');
      return await _getLocalRoutes();
    }
  }

  // Get routes as stream for real-time updates
  Stream<List<Map<String, dynamic>>> getRoutesStream() {
    return _firebaseRouteService.getRoutesStream();
  }

  // Get local routes as fallback
  Future<List<Map<String, dynamic>>> _getLocalRoutes() async {
    try {
      print('Loading routes from local database.json file');
      final String jsonString = await rootBundle.loadString('database.json');
      final List<dynamic> data = json.decode(jsonString);
      final routes = List<Map<String, dynamic>>.from(data);
      print('Successfully loaded ${routes.length} routes from local file');
      return routes;
    } catch (e) {
      print('Error loading local routes: $e');
      return [];
    }
  }

  // Add new route (Firebase only)
  Future<bool> addRoute(Map<String, dynamic> routeData) async {
    return await _firebaseRouteService.addRoute(routeData);
  }

  // Update existing route (Firebase only)
  Future<bool> updateRoute(
    String routeId,
    Map<String, dynamic> routeData,
  ) async {
    return await _firebaseRouteService.updateRoute(routeId, routeData);
  }

  // Delete route (Firebase only)
  Future<bool> deleteRoute(String routeId) async {
    return await _firebaseRouteService.deleteRoute(routeId);
  }

  // Batch upload routes (useful for admin operations)
  Future<bool> batchUploadRoutes(List<Map<String, dynamic>> routes) async {
    return await _firebaseRouteService.batchUploadRoutes(routes);
  }

  // Legacy methods for backward compatibility

  // Get routes by route number
  Future<List<Map<String, dynamic>>> getRoutesByNumber(
    String routeNumber,
  ) async {
    final allRoutes = await getRoutes();
    return allRoutes.where((route) => route['Route'] == routeNumber).toList();
  }

  // Get routes by schedule type
  Future<List<Map<String, dynamic>>> getRoutesBySchedule(
    String scheduleType,
  ) async {
    final allRoutes = await getRoutes();
    return allRoutes
        .where((route) => route['Schedule'] == scheduleType)
        .toList();
  }

  // Get routes by direction
  Future<List<Map<String, dynamic>>> getRoutesByDirection(
    String direction,
  ) async {
    final allRoutes = await getRoutes();
    return allRoutes
        .where(
          (route) =>
              route['Trip Direction']?.toString().toLowerCase().contains(
                direction.toLowerCase(),
              ) ??
              false,
        )
        .toList();
  }

  // Search routes by query
  Future<List<Map<String, dynamic>>> searchRoutes(String query) async {
    final allRoutes = await getRoutes();
    final lowercaseQuery = query.toLowerCase();

    return allRoutes.where((route) {
      final routeName = route['Route Name']?.toString().toLowerCase() ?? '';
      final stops = route['Stops']?.toString().toLowerCase() ?? '';
      final routeNumber = route['Route']?.toString().toLowerCase() ?? '';

      return routeName.contains(lowercaseQuery) ||
          stops.contains(lowercaseQuery) ||
          routeNumber.contains(lowercaseQuery);
    }).toList();
  }

  // Get unique route numbers
  Future<List<String>> getUniqueRouteNumbers() async {
    final allRoutes = await getRoutes();
    final routeNumbers =
        allRoutes
            .map((route) => route['Route']?.toString() ?? '')
            .where((route) => route.isNotEmpty)
            .toSet()
            .toList();
    routeNumbers.sort();
    return routeNumbers;
  }

  // Get available schedule types
  Future<List<String>> getScheduleTypes() async {
    final allRoutes = await getRoutes();
    final scheduleTypes =
        allRoutes
            .map((route) => route['Schedule']?.toString() ?? '')
            .where((schedule) => schedule.isNotEmpty)
            .toSet()
            .toList();
    scheduleTypes.sort();
    return scheduleTypes;
  }
}
