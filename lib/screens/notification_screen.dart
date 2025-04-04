import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import 'bus_schedule_screen.dart';
import 'dart:async';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<dynamic> notifications = [];
  bool isLoading = true;
  String currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) => _updateTime());
    _loadNotifications();
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

  Future<void> _loadNotifications() async {
    try {
      final data = await _notificationService.getNotifications();
      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final data = await _notificationService.getNotifications(forceRefresh: true);
      setState(() {
        notifications = data;
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error refreshing notifications: $e');
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update notifications'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 88, 13, 218),
      endDrawer: _buildSidebar(context),
      body: Stack(
        children: [
          // Fixed purple header - updated to match bus_schedule_screen.dart
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
                        'Notifications',
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
                        onPressed: _refreshNotifications,
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

          // Scrollable content area - updated to match bus_schedule_screen.dart
          Positioned(
            top: 140, // Changed from 100 to 140 to match bus_schedule_screen
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
                    : notifications.isEmpty
                        ? Center(
                            child: Text(
                              'No notifications available',
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              // Updated card design to match the image
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date header with purple background
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 88, 13, 218),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(7),
                                          topRight: Radius.circular(7),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            notification['date'] ?? '',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Notification title
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        notification['title'] ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align content to the bottom
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
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
