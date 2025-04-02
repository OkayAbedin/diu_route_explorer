import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class BusScheduleScreen extends StatefulWidget {
  @override
  _BusScheduleScreenState createState() => _BusScheduleScreenState();
}

class _BusScheduleScreenState extends State<BusScheduleScreen> {

  String currentTime = '';
  Timer? _timer;

  // Data from JSON
  List<dynamic> busData = [];
  Map<String, List<String>> scheduleRoutes = {
    'Regular': [],
    'Shuttle': [],
    'Friday': [],
  };
  List<String> availableRoutes = [];
  List<Map<String, dynamic>> startTimes = [];
  List<Map<String, dynamic>> departureTimes = [];
  bool isLoading = true;
  String selectedSchedule = 'Regular';
  String selectedRoute = '';  // Will be set to R1 after data loads
  
  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update time every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) => _updateTime());

    // Load data from JSON
    _loadBusData();
  }

  Future<void> _loadBusData() async {
    try {
      // Load the JSON file from assets
      final String response = await rootBundle.loadString(
        'assets/database.json',
      );
      final data = await json.decode(response);

      setState(() {
        busData = data;

        // Group routes by schedule type
        for (var item in busData) {
          String routeCode = item['Route'];
          String routeName = "${routeCode} - ${item['Route Name']}";
          String schedule = item['Schedule'];

          // Map route codes to schedule types
          if (schedule == 'Regular' &&
              !scheduleRoutes['Regular']!.contains(routeName)) {
            scheduleRoutes['Regular']!.add(routeName);
          } else if (schedule == 'Shuttle' &&
              !scheduleRoutes['Shuttle']!.contains(routeName)) {
            scheduleRoutes['Shuttle']!.add(routeName);
          } else if (schedule == 'Friday' &&
              !scheduleRoutes['Friday']!.contains(routeName)) {
            scheduleRoutes['Friday']!.add(routeName);
          }
        }

        // Set available routes based on default selected schedule
        availableRoutes = scheduleRoutes[selectedSchedule] ?? [];
        
        // Find and set R1 as the default route if available
        String r1Route = availableRoutes.firstWhere(
          (route) => route.startsWith('R1 '),
          orElse: () => availableRoutes.isNotEmpty ? availableRoutes[0] : '',
        );
        
        selectedRoute = r1Route;
        _updateScheduleData();

        isLoading = false;
      });
    } catch (e) {
      print('Error loading bus data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateScheduleData() {
    if (selectedRoute.isEmpty) return;

    // Extract route code (R1, R2, etc.) from the selected route
    String routeCode = selectedRoute.split(' - ')[0];

    // Filter data based on selected route and schedule
    List<dynamic> filteredData =
        busData
            .where(
              (item) =>
                  item['Route'] == routeCode &&
                  item['Schedule'] == selectedSchedule,
            )
            .toList();

    // Separate into start times (To DSC) and departure times (From DSC)
    List<Map<String, dynamic>> newStartTimes = [];
    List<Map<String, dynamic>> newDepartureTimes = [];

    for (var item in filteredData) {
      if (item['Trip Direction'] == 'To DSC') {
        newStartTimes.add({
          'time': item['Time'],
          'note': item['Note'] ?? 'No additional information',
          'stops': item['Stops'],
        });
      } else if (item['Trip Direction'] == 'From DSC') {
        newDepartureTimes.add({
          'time': item['Time'],
          'note': item['Note'] ?? 'No additional information',
          'stops': item['Stops'],
        });
      }
    }

    setState(() {
      startTimes = newStartTimes;
      departureTimes = newDepartureTimes;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                top: 40,
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
                        'Welcome,',
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
                  Builder(
                    builder:
                        (context) => IconButton(
                          icon: Icon(Icons.menu, color: Colors.white, size: 30),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        ),
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
                    isLoading
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
                                // Schedule Selection (First)
                                Text(
                                  'Select Schedule',
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
                                      value: selectedSchedule,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedSchedule = newValue!;
                                          // Update available routes based on selected schedule
                                          availableRoutes =
                                              scheduleRoutes[selectedSchedule] ??
                                              [];
                                          // Reset selected route
                                          selectedRoute =
                                              availableRoutes.isNotEmpty
                                                  ? availableRoutes[0]
                                                  : '';
                                          _updateScheduleData();
                                        });
                                      },
                                      items:
                                          [
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

                                SizedBox(height: 16),

                                // Route Selection (Second)
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
                                          _updateScheduleData();
                                        });
                                      },
                                      items:
                                          availableRoutes
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

                                // Start Time Section
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 88, 13, 218),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'Start Time',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),

                                // Start Time Table
                                startTimes.isEmpty
                                    ? Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          'No start times available for this selection',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Table(
                                      border: TableBorder.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      children:
                                          startTimes.map<TableRow>((time) {
                                            return TableRow(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    time['time'] ?? '',
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    time['note'].isEmpty
                                                        ? 'No additional information'
                                                        : time['note'],
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),

                                SizedBox(height: 20),

                                // Departure Time Section
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 88, 13, 218),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'Departure Time',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),

                                // Departure Time Table
                                departureTimes.isEmpty
                                    ? Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          'No departure times available for this selection',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    )
                                    : Table(
                                      border: TableBorder.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      children:
                                          departureTimes.map<TableRow>((time) {
                                            return TableRow(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    time['time'] ?? '',
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(12),
                                                  child: Text(
                                                    time['note'].isEmpty
                                                        ? 'No additional information'
                                                        : time['note'],
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),

                                // Stops Information Section
                                if (startTimes.isNotEmpty ||
                                    departureTimes.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            88,
                                            13,
                                            218,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Route Stops',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          startTimes.isNotEmpty
                                              ? startTimes[0]['stops']
                                              : (departureTimes.isNotEmpty
                                                  ? departureTimes[0]['stops']
                                                  : 'No stops information available'),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
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
          ),
        ],
      ),
    );
  }

  // Implement the sidebar method
  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 88, 13, 218)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DIU Route Explorer',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Navigate your campus journey',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.directions_bus),
            title: Text('Bus Schedule'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Route Map'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to route map screen
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to about screen
            },
          ),
        ],
      ),
    );
  }
}
