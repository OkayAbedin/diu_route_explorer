import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RouteService {
  // URL to your GitHub Gist raw file with cache-busting
  String get _jsonUrl {
    // Add timestamp to prevent caching
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://gist.githubusercontent.com/diuRouteExplorer/51bef3438ba8e7e1056d2f902670bfe9/raw/database.json?timestamp=$timestamp';
  }

  Future<List<Map<String, dynamic>>> getRoutes({bool forceRefresh = false}) async {
    try {
      // Try to fetch from remote source first
      final response = await http.get(Uri.parse(_jsonUrl));

      if (response.statusCode == 200) {
        print('Successfully loaded routes from remote source');
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Failed to load routes from server: ${response.statusCode}');
        // Fallback to local data
        return await _getLocalRoutes();
      }
    } catch (e) {
      print('Error fetching routes: $e');
      // Fallback to local data if network fetch fails
      return await _getLocalRoutes();
    }
  }

  // Fallback method to load local data
  Future<List<Map<String, dynamic>>> _getLocalRoutes() async {
    print('Loading routes from local assets');
    // Load from local assets as a fallback
    final String response = await rootBundle.loadString('assets/database.json');
    final List<dynamic> data = json.decode(response);
    return List<Map<String, dynamic>>.from(data);
  }
}
