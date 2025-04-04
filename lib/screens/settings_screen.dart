import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/route_service.dart';
import 'dart:convert';
import 'dart:async';
import 'bus_schedule_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final RouteService _routeService = RouteService();
  final String _cacheKey = 'cached_route_data';
  final String _defaultRouteKey = 'default_route';

  bool _pushNotifications = true;
  bool _darkMode = false;
  String _selectedDefaultRoute = '';

  List<String> _availableRoutes = [];
  bool _isLoading = true;
  String currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) => _updateTime());
    _loadSettings();
    _loadRouteData();
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final hourString = hour == 0 ? '12' : hour.toString();
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    setState(() {
      currentTime = '$hourString:$minute $period';
    });
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _pushNotifications = prefs.getBool('push_notifications') ?? true;
        _darkMode = prefs.getBool('dark_mode') ?? false;
        _selectedDefaultRoute = prefs.getString(_defaultRouteKey) ?? '';
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications', _pushNotifications);
      await prefs.setBool('dark_mode', _darkMode);
      await prefs.setString(_defaultRouteKey, _selectedDefaultRoute);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settings updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadRouteData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _routeService.getRoutes();
      _processRouteData(data);
    } catch (e) {
      print('Error loading route data: $e');
      _loadFromCache();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);

      if (jsonString != null) {
        final data = json.decode(jsonString);
        _processRouteData(List<dynamic>.from(data));
      }
    } catch (e) {
      print('Error loading from cache: $e');
    }
  }

  void _processRouteData(List<dynamic> data) {
    // Get all unique routes
    Set<String> uniqueRoutes = {};

    for (var route in data) {
      String routeCode = route['Route'];
      String routeName = route['Route Name'];
      uniqueRoutes.add('$routeCode - $routeName');
    }

    setState(() {
      _availableRoutes = uniqueRoutes.toList();
      _availableRoutes.sort();

      // If no default route is selected yet, and we have routes available
      if (_selectedDefaultRoute.isEmpty && _availableRoutes.isNotEmpty) {
        _selectedDefaultRoute = _availableRoutes[0];
        _saveSettings();
      } else if (!_availableRoutes.contains(_selectedDefaultRoute) &&
          _availableRoutes.isNotEmpty) {
        // If the saved default route is no longer available
        _selectedDefaultRoute = _availableRoutes[0];
        _saveSettings();
      }
    });
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: _loadRouteData,
                      ),
                      Builder(
                        builder:
                            (context) => IconButton(
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
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 88, 13, 218),
                          ),
                        )
                        : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Default Route Section
                              Text(
                                'Default Route',
                                style: GoogleFonts.inter(
                                  color: Color.fromARGB(255, 88, 13, 218),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
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
                                    value:
                                        _availableRoutes.contains(
                                              _selectedDefaultRoute,
                                            )
                                            ? _selectedDefaultRoute
                                            : (_availableRoutes.isNotEmpty
                                                ? _availableRoutes[0]
                                                : null),
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedDefaultRoute = newValue;
                                        });
                                        _saveSettings();
                                      }
                                    },
                                    items:
                                        _availableRoutes
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

                              SizedBox(height: 24),

                              // Push Notification Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Push Notification',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Switch(
                                    value: _pushNotifications,
                                    onChanged: (value) {
                                      setState(() {
                                        _pushNotifications = value;
                                      });
                                      _saveSettings();
                                    },
                                    activeColor: Color.fromARGB(
                                      255,
                                      88,
                                      13,
                                      218,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),

                              // Dark Mode Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Switch(
                                    value: _darkMode,
                                    onChanged: (value) {
                                      setState(() {
                                        _darkMode = value;
                                      });
                                      _saveSettings();
                                    },
                                    activeColor: Color.fromARGB(
                                      255,
                                      88,
                                      13,
                                      218,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BusScheduleScreen()),
              );
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
              Navigator.pushNamed(context, '/route_information');
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
              Navigator.pushNamed(context, '/notifications');
            },
          ),

          Divider(height: 1, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.settings),
            title: Text('Settings', style: GoogleFonts.inter(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
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
