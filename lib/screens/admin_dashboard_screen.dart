import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/admin_service.dart';
import '../services/database_service.dart';
import 'route_editor_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final DatabaseService _databaseService = DatabaseService();
  
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;
  String _filterSchedule = 'All';
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }
  
  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final routes = await _databaseService.getDatabase();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading routes: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Only show error message if the context is still valid
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load routes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Add this method to handle SharedPreferences errors
  Future<void> _safeLogout() async {
    try {
      await _adminService.logout();
    } catch (e) {
      print('Error during logout: $e');
      // Continue with navigation even if logout fails
    }
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  
  List<Map<String, dynamic>> _getFilteredRoutes() {
    return _routes.where((route) {
      // Apply schedule filter
      if (_filterSchedule != 'All' && route['Schedule'] != _filterSchedule) {
        return false;
      }
      
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final routeName = route['Route Name']?.toString().toLowerCase() ?? '';
        final routeCode = route['Route']?.toString().toLowerCase() ?? '';
        final searchLower = _searchQuery.toLowerCase();
        
        return routeName.contains(searchLower) || routeCode.contains(searchLower);
      }
      
      return true;
    }).toList();
  }
  
  // Replace the existing _logout method with this one
  Future<void> _logout() async {
  // Use the safe logout method instead
  await _safeLogout();
  }
  
  Future<void> _deleteRoute(int index) async {
    final filteredRoutes = _getFilteredRoutes();
    final routeToDelete = filteredRoutes[index];
    final originalIndex = _routes.indexOf(routeToDelete);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final success = await _databaseService.deleteRoute(originalIndex);
        
        if (success) {
          await _loadRoutes();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Route deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete route'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('Error deleting route: $e');
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting route: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final filteredRoutes = _getFilteredRoutes();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 88, 13, 218),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 88, 13, 218),
        child: Icon(Icons.add),
        onPressed: () async {
          try {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteEditorScreen(isNewRoute: true),
              ),
            );
            
            if (result == true) {
              await _loadRoutes();
            }
          } catch (e) {
            print('Error adding route: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding route: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search routes...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Filter by: ', style: GoogleFonts.inter()),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _filterSchedule,
                      items: ['All', 'Regular', 'Shuttle', 'Friday']
                          .map((schedule) => DropdownMenuItem(
                                value: schedule,
                                child: Text(schedule),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _filterSchedule = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Routes list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 88, 13, 218),
                    ),
                  )
                : filteredRoutes.isEmpty
                    ? Center(
                        child: Text(
                          'No routes found',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRoutes,
                        child: ListView.builder(
                          itemCount: filteredRoutes.length,
                          itemBuilder: (context, index) {
                            final route = filteredRoutes[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: Text(
                                  '${route['Route']} - ${route['Route Name']}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${route['Schedule']} | ${route['Trip Direction']} | ${route['Time']}',
                                  style: GoogleFonts.inter(),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        try {
                                          final originalIndex = _routes.indexOf(route);
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RouteEditorScreen(
                                                isNewRoute: false,
                                                route: route,
                                                routeIndex: originalIndex,
                                              ),
                                            ),
                                          );
                                          
                                          if (result == true) {
                                            await _loadRoutes();
                                          }
                                        } catch (e) {
                                          print('Error editing route: $e');
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error editing route: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteRoute(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}