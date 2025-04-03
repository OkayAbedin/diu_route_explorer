import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/route_service.dart';

class DatabaseService {
  final RouteService _routeService = RouteService();
  
  // GitHub API endpoint for updating Gist
  // Note: You'll need to use a GitHub token with Gist permissions
  final String _githubApiUrl = 'https://api.github.com/gists/51bef3438ba8e7e1056d2f902670bfe9';
  final String _githubToken = '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'; // Store this securely in production
  
  // Get current database
  Future<List<Map<String, dynamic>>> getDatabase() async {
    return await _routeService.getRoutes();
  }
  
  // Update database
  Future<bool> updateDatabase(List<Map<String, dynamic>> newData) async {
    try {
      // Convert data to JSON string
      final String jsonData = json.encode(newData);
      
      // Prepare request body for GitHub API
      final Map<String, dynamic> requestBody = {
        'files': {
          'database.json': {
            'content': jsonData
          }
        }
      };
      
      // Send PATCH request to update Gist
      final response = await http.patch(
        Uri.parse(_githubApiUrl),
        headers: {
          'Authorization': 'token $_githubToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating database: $e');
      return false;
    }
  }
  
  // Add a new route
  Future<bool> addRoute(Map<String, dynamic> newRoute) async {
    try {
      final database = await getDatabase();
      database.add(newRoute);
      return await updateDatabase(database);
    } catch (e) {
      print('Error adding route: $e');
      return false;
    }
  }
  
  // Update an existing route
  Future<bool> updateRoute(int index, Map<String, dynamic> updatedRoute) async {
    try {
      final database = await getDatabase();
      if (index >= 0 && index < database.length) {
        database[index] = updatedRoute;
        return await updateDatabase(database);
      }
      return false;
    } catch (e) {
      print('Error updating route: $e');
      return false;
    }
  }
  
  // Delete a route
  Future<bool> deleteRoute(int index) async {
    try {
      final database = await getDatabase();
      if (index >= 0 && index < database.length) {
        database.removeAt(index);
        return await updateDatabase(database);
      }
      return false;
    } catch (e) {
      print('Error deleting route: $e');
      return false;
    }
  }
}