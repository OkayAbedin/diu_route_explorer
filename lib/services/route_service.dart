import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_route_service.dart';

class RouteService {
  final FirebaseRouteService _firebaseRouteService = FirebaseRouteService();
  static const String _cacheKey = 'cached_route_data';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 6); // Cache for 6 hours

  // In-memory cache for faster access
  static List<Map<String, dynamic>>? _memoryCache;
  static DateTime? _memoryCacheTimestamp;
  // Get routes from Firebase (with fallback to local)
  Future<List<Map<String, dynamic>>> getRoutes({
    bool forceRefresh = false,
  }) async {
    try {
      // Check memory cache first for fastest access
      if (!forceRefresh &&
          _memoryCache != null &&
          _memoryCacheTimestamp != null) {
        final cacheAge = DateTime.now().difference(_memoryCacheTimestamp!);
        if (cacheAge < _cacheExpiry) {
          print('Returning routes from memory cache');
          return _memoryCache!;
        }
      }

      // Check persistent cache if memory cache is stale
      if (!forceRefresh) {
        final cachedRoutes = await _getCachedRoutes();
        if (cachedRoutes != null) {
          _memoryCache = cachedRoutes;
          _memoryCacheTimestamp = DateTime.now();
          print('Returning routes from persistent cache');
          return cachedRoutes;
        }
      }

      print('Fetching routes from Firebase...');

      // Try to fetch from Firebase first
      final routes = await _firebaseRouteService.getRoutes(
        forceRefresh: forceRefresh,
      );

      if (routes.isNotEmpty) {
        print('Successfully loaded ${routes.length} routes from Firebase');
        // Cache the fresh data
        await _cacheRoutes(routes);
        _memoryCache = routes;
        _memoryCacheTimestamp = DateTime.now();
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

  // Cache routes to persistent storage
  Future<void> _cacheRoutes(List<Map<String, dynamic>> routes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(routes);
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error caching routes: $e');
    }
  }

  // Get cached routes from persistent storage
  Future<List<Map<String, dynamic>>?> _getCachedRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (jsonString != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final cacheAge = DateTime.now().difference(cacheTime);

        if (cacheAge < _cacheExpiry) {
          final List<dynamic> data = json.decode(jsonString);
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return null;
    } catch (e) {
      print('Error getting cached routes: $e');
      return null;
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

  // Batch upload routes
  Future<bool> batchUploadRoutes(List<Map<String, dynamic>> routes) async {
    return await _firebaseRouteService.batchUploadRoutes(routes);
  }
}
