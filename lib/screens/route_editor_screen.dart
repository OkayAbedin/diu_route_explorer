import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';

class RouteEditorScreen extends StatefulWidget {
  final bool isNewRoute;
  final Map<String, dynamic>? route;
  final int? routeIndex;
  
  RouteEditorScreen({
    required this.isNewRoute,
    this.route,
    this.routeIndex,
  });
  
  @override
  _RouteEditorScreenState createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<RouteEditorScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _routeCodeController;
  late TextEditingController _routeNameController;
  late TextEditingController _timeController;
  late TextEditingController _stopsController;
  late TextEditingController _noteController;
  late TextEditingController _routeMapController;
  
  String _schedule = 'Regular';
  String _tripDirection = 'To DSC';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    if (!widget.isNewRoute && widget.route != null) {
      final route = widget.route!;
      _routeCodeController = TextEditingController(text: route['Route']);
      _routeNameController = TextEditingController(text: route['Route Name']);
      _timeController = TextEditingController(text: route['Time']);
      _stopsController = TextEditingController(text: route['Stops']);
      _noteController = TextEditingController(text: route['Note'] ?? '');
      _routeMapController = TextEditingController(text: route['Route Map'] ?? '');
      _schedule = route['Schedule'];
      _tripDirection = route['Trip Direction'];
    } else {
      // Initialize with empty values for new route
      _routeCodeController = TextEditingController();
      _routeNameController = TextEditingController();
      _timeController = TextEditingController();
      _stopsController = TextEditingController();
      _noteController = TextEditingController();
      _routeMapController = TextEditingController();
    }
  }
  
  @override
  void dispose() {
    _routeCodeController.dispose();
    _routeNameController.dispose();
    _timeController.dispose();
    _stopsController.dispose();
    _noteController.dispose();
    _routeMapController.dispose();
    super.dispose();
  }
  
  Future<void> _saveRoute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final routeData = {
      'Route': _routeCodeController.text,
      'Schedule': _schedule,
      'Route Name': _routeNameController.text,
      'Trip Direction': _tripDirection,
      'Time': _timeController.text,
      'Stops': _stopsController.text,
      'Note': _noteController.text,
      'Route Map': _routeMapController.text,
    };
    
    bool success;
    
    if (widget.isNewRoute) {
      success = await _databaseService.addRoute(routeData);
    } else {
      success = await _databaseService.updateRoute(widget.routeIndex!, routeData);
    }
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isNewRoute ? 'Route added successfully' : 'Route updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isNewRoute ? 'Failed to add route' : 'Failed to update route'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNewRoute ? 'Add New Route' : 'Edit Route',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 88, 13, 218),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 88, 13, 218),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Code
                    TextFormField(
                      controller: _routeCodeController,
                      decoration: InputDecoration(
                        labelText: 'Route Code (e.g., R1, F1)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a route code';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Schedule Type
                    Text('Schedule Type', style: GoogleFonts.inter(fontSize: 16)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _schedule,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ['Regular', 'Shuttle', 'Friday']
                          .map((schedule) => DropdownMenuItem(
                                value: schedule,
                                child: Text(schedule),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _schedule = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Route Name
                    TextFormField(
                      controller: _routeNameController,
                      decoration: InputDecoration(
                        labelText: 'Route Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a route name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Trip Direction
                    Text('Trip Direction', style: GoogleFonts.inter(fontSize: 16)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _tripDirection,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ['To DSC', 'From DSC']
                          .map((direction) => DropdownMenuItem(
                                value: direction,
                                child: Text(direction),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _tripDirection = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Time
                    TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Time (e.g., 7:00 AM)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a time';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Stops
                    TextFormField(
                      controller: _stopsController,
                      decoration: InputDecoration(
                        labelText: 'Stops (comma separated)',
                        border: OutlineInputBorder(),
                        hintText: 'Stop 1, Stop 2, Stop 3, ...',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stops';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Note
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    
                    // Route Map
                    TextFormField(
                      controller: _routeMapController,
                      decoration: InputDecoration(
                        labelText: 'Route Map URL (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 88, 13, 218),
                        ),
                        onPressed: _saveRoute,
                        child: Text(
                          widget.isNewRoute ? 'Add Route' : 'Update Route',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}