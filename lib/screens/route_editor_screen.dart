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
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isNewRoute ? 'Failed to add route' : 'Failed to update route'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 88, 13, 218),
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
                        widget.isNewRoute ? 'Add New Route' : 'Edit Route',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Enter route details below',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 88, 13, 218),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Route Code
                            Text(
                              'Route Code',
                              style: GoogleFonts.inter(
                                color: Color.fromARGB(255, 88, 13, 218),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _routeCodeController,
                              decoration: InputDecoration(
                                hintText: 'e.g., R1, F1',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                            Text(
                              'Schedule Type',
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
                                  value: _schedule,
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _schedule = newValue!;
                                    });
                                  },
                                  items: ['Regular', 'Shuttle', 'Friday']
                                    .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            
                            // Route Name
                            Text(
                              'Route Name',
                              style: GoogleFonts.inter(
                                color: Color.fromARGB(255, 88, 13, 218),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _routeNameController,
                              decoration: InputDecoration(
                                hintText: 'e.g., DSC <> Dhanmondi',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                            Text(
                              'Trip Direction',
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
                                  value: _tripDirection,
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _tripDirection = newValue!;
                                    });
                                  },
                                  items: ['To DSC', 'From DSC']
                                    .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            
                            // Time
                            Text(
                              'Time',
                              style: GoogleFonts.inter(
                                color: Color.fromARGB(255, 88, 13, 218),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _timeController,
                              decoration: InputDecoration(
                                hintText: 'e.g., 7:00 AM',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                            Text(
                              'Stops',
                              style: GoogleFonts.inter(
                                color: Color.fromARGB(255, 88, 13, 218),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _stopsController,
                              decoration: InputDecoration(
                                hintText: 'Stop 1, Stop 2, Stop 3, ...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: EdgeInsets.all(12),
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
                            Text(
                              'Note (optional)',
                              style: GoogleFonts.inter(
                                color: Color.fromARGB(255, 88, 13, 218),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                hintText: 'Additional information about this route',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: EdgeInsets.all(12),
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 16),
                            
                            // Route Map
                            Text(
                              'Route Map URL (optional)',
                              style: GoogleFonts.inter(
                                color: Color.fromARGB(255, 88, 13, 218),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _routeMapController,
                              decoration: InputDecoration(
                                hintText: 'https://example.com/map',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                            ),
                            SizedBox(height: 30),
                            
                            // Save Button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 88, 13, 218),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextButton(
                                onPressed: _saveRoute,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    widget.isNewRoute ? 'Add Route' : 'Update Route',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
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
}