import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RouteService {
  // URL to your GitHub Gist raw file
  final String _jsonUrl = 'https://gist.githubusercontent.com/OkayAbedin/f102235c6d63b9d9552e194b414de91b/raw/6cef2524c32ced44ac38946d420c092d67d1edf6/database.json';
  
  Future<List<Map<String, dynamic>>> getRoutes() async {
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