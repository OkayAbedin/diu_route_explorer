import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/route_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RouteInformationScreen extends StatefulWidget {
  @override
  _RouteInformationScreenState createState() => _RouteInformationScreenState();
}

class _RouteInformationScreenState extends State<RouteInformationScreen> {
  final RouteService _routeService = RouteService();
  final String _cacheKey = 'cached_route_data';
  
  List<dynamic> routeData = [];
  Map<String, List<String>> routesByType = {};
  List<String> availableRoutes = [];
  String selectedRoute = '';
  Map<String, dynamic> selectedRouteDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  Future<void> _loadRouteData() async {
    try {
      final data = await _routeService.getRoutes();
      _cacheData(data);

      setState(() {
        routeData = data;
        _processRouteData();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading route data: $e');
      _loadFromCache();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _processRouteData() {
    // Group routes by type
    routesByType = {};
    
    // Get unique routes
    Set<String> uniqueRoutes = {};
    
    for (var item in routeData) {
      String routeCode = item['Route'];
      String routeName = item['Route Name'];
      String fullRouteName = "$routeCode - $routeName";
      
      // Only add each route once
      if (!uniqueRoutes.contains(fullRouteName)) {
        uniqueRoutes.add(fullRouteName);
        
        // Skip R1 - DSC <> Dhanmondi
        if (fullRouteName.contains("R1 - DSC <> Dhanmondi")) {
          continue;
        }
        
        availableRoutes.add(fullRouteName);
      }
    }
    
    // Set default selected route
    if (availableRoutes.isNotEmpty && selectedRoute.isEmpty) {
      selectedRoute = availableRoutes[0];
      _updateRouteDetails();
    }
  }

  void _updateRouteDetails() {
    if (selectedRoute.isEmpty) return;

    // Extract route code (R1, R2, etc.) from the selected route
    String routeCode = selectedRoute.split(' - ')[0];

    // Find the first matching route data
    for (var item in routeData) {
      if (item['Route'] == routeCode) {
        setState(() {
          selectedRouteDetails = Map<String, dynamic>.from(item);
        });
        break;
      }
    }
  }

  Future<void> _cacheData(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(data);
      await prefs.setString(_cacheKey, jsonString);
      print('Route data cached successfully');
    } catch (e) {
      print('Error caching route data: $e');
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      
      if (jsonString != null) {
        final data = json.decode(jsonString);
        
        setState(() {
          routeData = List<dynamic>.from(data);
          _processRouteData();
        });
        
        print('Loaded route data from cache');
      }
    } catch (e) {
      print('Error loading from cache: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final data = await _routeService.getRoutes(forceRefresh: true);
      _cacheData(data);
      
      setState(() {
        routeData = data;
        _processRouteData();
        _updateRouteDetails();
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Route data updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error refreshing data: $e');
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update route data'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openGoogleMaps() async {
    if (selectedRouteDetails.containsKey('Route Map') && 
        selectedRouteDetails['Route Map'] != null && 
        selectedRouteDetails['Route Map'].toString().isNotEmpty) {
      
      String mapUrl = selectedRouteDetails['Route Map'];
      
      if (await canLaunch(mapUrl)) {
        await launch(mapUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open map link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No map link available for this route'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 88, 13, 218),
      endDrawer: _buildSidebar(context),
      body: Stack(
        children: [
          // Fixed purple header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              color: Color.fromARGB(255, 88, 13, 218),
              padding: EdgeInsets.only(
                top: 60,
                bottom: 15,
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Route Information',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: _refreshData,
                      ),
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Scrollable content area
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 88, 13, 218),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                  ),
                ),
                child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 88, 13, 218),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Route Selection
                            Text(
                              'Select Route',
                              style: GoogleFonts.inter(
                                color: Color.fromARGB(255, 88, 13, 218),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedRoute,
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedRoute = newValue!;
                                      _updateRouteDetails();
                                    });
                                  },
                                  items: availableRoutes
                                    .map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    })
                                    .toList(),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Route Details
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 88, 13, 218),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Route Details',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            // Route Stops
                            if (selectedRouteDetails.isNotEmpty && 
                                selectedRouteDetails.containsKey('Stops'))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  // Removed the 'Route Stops' text and its padding
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: selectedRouteDetails['Stops']
                                        .split(',')
                                        .map<Widget>(
                                          (stop) => Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '$stop',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    ),
                                  ),
                                ],
                              ),

                            SizedBox(height: 20),

                            // Google Maps Button
                            Container(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _openGoogleMaps,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 88, 13, 218),
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'View Map in Google Maps',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Purple header with app description
          Container(
            width: double.infinity,
            height: 240,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            color: const Color.fromARGB(255, 88, 13, 218),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DIU Route Explorers is a university bus schedule app that allows students to check bus routes, start and departure times, and important notes for a smooth commuting experience.',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.2,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu items with improved spacing
          SizedBox(height: 30),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.schedule),
            title: Text('Bus Schedule', style: GoogleFonts.inter(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/bus_schedule');
            },
          ),

          Divider(height: 1, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.route),
            title: Text(
              'Route Information',
              style: GoogleFonts.inter(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          Divider(height: 1, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.notifications),
            title: Text(
              'Notifications',
              style: GoogleFonts.inter(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/notifications');
            },
          ),

          Divider(height: 1, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.settings),
            title: Text('Settings', style: GoogleFonts.inter(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          Divider(height: 1, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.help),
            title: Text(
              'Help and Support',
              style: GoogleFonts.inter(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          Divider(height: 1, thickness: 0.5),

          // Logout at the bottom with red text
          Spacer(),
          Divider(height: 1, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Logout',
              style: GoogleFonts.inter(color: Colors.red, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          // Version and footer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Text(
                  'Version 1.0.1',
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Made with ", style: GoogleFonts.inter(fontSize: 12)),
                    Icon(Icons.favorite, color: Colors.red, size: 12),
                    Text(" by ", style: GoogleFonts.inter(fontSize: 12)),
                    Text(
                      "MarsLab",
                      style: GoogleFonts.inter(
                        color: Color.fromARGB(255, 88, 13, 218),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}