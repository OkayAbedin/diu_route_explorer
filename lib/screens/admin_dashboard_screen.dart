import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'route_editor_screen.dart';
import 'dart:async';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Removed unused AdminService field
  final DatabaseService _databaseService = DatabaseService();

  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;
  String _filterSchedule = 'All';
  String _searchQuery = '';
  String currentTime = '';
  String adminName = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
    _updateTime();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) => _updateTime());
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    try {
      final AuthService authService = AuthService();
      final name = await authService.getUserName();
      setState(() {
        adminName = name;
      });
    } catch (e) {
      print('Error loading admin name: $e');
    }
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
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Add this method to handle SharedPreferences errors
  Future<void> _safeLogout() async {
    try {
      // Use AuthService for consistent logout experience
      final authService = AuthService();
      await authService.logout();
    } catch (e) {
      print('Error during logout: $e');
      // Continue with navigation even if logout fails
    }

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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

        return routeName.contains(searchLower) ||
            routeCode.contains(searchLower);
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

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
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
        ) ??
        false;

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
                duration: Duration(seconds: 2),
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
                duration: Duration(seconds: 2),
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
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
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
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align content to the bottom
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Dashboard for DIU Route Explorers allows you to manage bus routes, schedules, and provide students with accurate transportation information.',
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
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard', style: GoogleFonts.inter(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          Divider(height: 1, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.route),
            title: Text(
              'Manage Routes',
              style: GoogleFonts.inter(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          Divider(height: 1, thickness: 0.5),

          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Icon(Icons.analytics),
            title: Text('Analytics', style: GoogleFonts.inter(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
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
            onTap: _logout,
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

  @override
  Widget build(BuildContext context) {
    final filteredRoutes = _getFilteredRoutes();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 88, 13, 218),
      endDrawer: _buildSidebar(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromARGB(255, 88, 13, 218),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Route',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 8,
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
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
      ),
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
                        'Welcome Admin,',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'it\'s $currentTime now.',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
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
                        onPressed: _loadRoutes,
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
                        : Column(
                          children: [
                            // Search and filter bar
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Search Routes',
                                    style: GoogleFonts.inter(
                                      color: Color.fromARGB(255, 88, 13, 218),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search routes...',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Filter by Schedule',
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
                                        value: _filterSchedule,
                                        isExpanded: true,
                                        icon: Icon(Icons.arrow_drop_down),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _filterSchedule = newValue!;
                                          });
                                        },
                                        items:
                                            [
                                              'All',
                                              'Regular',
                                              'Shuttle',
                                              'Friday',
                                            ].map<DropdownMenuItem<String>>((
                                              String value,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Routes list
                            Expanded(
                              child:
                                  filteredRoutes.isEmpty
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
                                        color: Color.fromARGB(255, 88, 13, 218),
                                        child: ListView.builder(
                                          itemCount: filteredRoutes.length,
                                          itemBuilder: (context, index) {
                                            final route = filteredRoutes[index];
                                            return Card(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              elevation: 4,
                                              shadowColor: Colors.black26,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                side: BorderSide(
                                                  color: Colors.grey.shade200,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '${route['Route']} - ${route['Route Name']}',
                                                            style: GoogleFonts.inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  16, // Reduced from 18 to 16
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    88,
                                                                    13,
                                                                    218,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                route['Schedule'] ==
                                                                        'Regular'
                                                                    ? Colors
                                                                        .blue
                                                                        .shade100
                                                                    : route['Schedule'] ==
                                                                        'Shuttle'
                                                                    ? Colors
                                                                        .green
                                                                        .shade100
                                                                    : Colors
                                                                        .orange
                                                                        .shade100,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            route['Schedule'],
                                                            style: GoogleFonts.inter(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  route['Schedule'] ==
                                                                          'Regular'
                                                                      ? Colors
                                                                          .blue
                                                                          .shade800
                                                                      : route['Schedule'] ==
                                                                          'Shuttle'
                                                                      ? Colors
                                                                          .green
                                                                          .shade800
                                                                      : Colors
                                                                          .orange
                                                                          .shade800,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 12),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.directions_bus,
                                                          size: 16,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade700,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          route['Trip Direction'],
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontSize: 14,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade700,
                                                              ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Icon(
                                                          Icons.access_time,
                                                          size: 16,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade700,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          route['Time'],
                                                          style:
                                                              GoogleFonts.inter(
                                                                fontSize: 14,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade700,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (route['Note'] != null &&
                                                        route['Note']
                                                            .toString()
                                                            .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              top: 12,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade100,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .info_outline,
                                                                size: 16,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade700,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  route['Note'],
                                                                  style: GoogleFonts.inter(
                                                                    fontSize:
                                                                        13,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    SizedBox(height: 12),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        ElevatedButton.icon(
                                                          icon: Icon(
                                                            Icons.edit,
                                                            size: 18,
                                                          ),
                                                          label: Text('Edit'),
                                                          style: ElevatedButton.styleFrom(
                                                            foregroundColor:
                                                                Color.fromARGB(
                                                                  255,
                                                                  88,
                                                                  13,
                                                                  218,
                                                                ),
                                                            backgroundColor:
                                                                Colors.white,
                                                            elevation: 0,
                                                            side: BorderSide(
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    88,
                                                                    13,
                                                                    218,
                                                                  ),
                                                            ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                          ),
                                                          onPressed: () async {
                                                            try {
                                                              final originalIndex =
                                                                  _routes
                                                                      .indexOf(
                                                                        route,
                                                                      );
                                                              final result = await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => RouteEditorScreen(
                                                                        isNewRoute:
                                                                            false,
                                                                        route:
                                                                            route,
                                                                        routeIndex:
                                                                            originalIndex,
                                                                      ),
                                                                ),
                                                              );

                                                              if (result ==
                                                                  true) {
                                                                await _loadRoutes();
                                                              }
                                                            } catch (e) {
                                                              print(
                                                                'Error editing route: $e',
                                                              );
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Error editing route: $e',
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    duration:
                                                                        Duration(
                                                                          seconds:
                                                                              2,
                                                                        ),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          },
                                                        ),
                                                        SizedBox(width: 8),
                                                        ElevatedButton.icon(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            size: 18,
                                                            color:
                                                                Colors
                                                                    .white, // Changed to white for better contrast
                                                          ),
                                                          label: Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ), // Changed to white
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            foregroundColor:
                                                                Colors
                                                                    .white, // Changed from red to white
                                                            backgroundColor:
                                                                Colors
                                                                    .red, // Changed from white to red
                                                            elevation: 0,
                                                            side: BorderSide(
                                                              color: Colors.red,
                                                            ),
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8,
                                                                ),
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  _deleteRoute(
                                                                    index,
                                                                  ),
                                                        ),
                                                      ],
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
