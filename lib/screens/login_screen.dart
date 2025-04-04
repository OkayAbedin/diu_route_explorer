import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bus_schedule_screen.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isUserLogin = true; // Track active tab
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    studentIdController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      endDrawer: _buildSidebar(context),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Purple header section
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 88, 13, 218),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50), // Space for the menu icon
                      Spacer(), // Add spacer to push text to bottom
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "DIU\nROUTE\nEXPLORER",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // White content section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User/Admin Login Tabs with Underline Indicator
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isUserLogin = true;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "User Login",
                                      style: TextStyle(
                                        color:
                                            isUserLogin
                                                ? Color.fromARGB(
                                                  255,
                                                  88,
                                                  13,
                                                  218,
                                                )
                                                : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 3,
                                      color:
                                          isUserLogin
                                              ? Color.fromARGB(255, 88, 13, 218)
                                              : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isUserLogin = false;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Admin Login",
                                      style: TextStyle(
                                        color:
                                            !isUserLogin
                                                ? Color.fromARGB(
                                                  255,
                                                  88,
                                                  13,
                                                  218,
                                                )
                                                : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 3,
                                      color:
                                          !isUserLogin
                                              ? Color.fromARGB(255, 88, 13, 218)
                                              : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // Conditional form fields based on selected tab
                      if (isUserLogin) ...[
                        // User Login Form
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            TextField(
                              controller: studentIdController,
                              decoration: InputDecoration(
                                hintText: "Enter your Student ID",
                                hintStyle: TextStyle(color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 88, 13, 218),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 88, 13, 218),
                                  ),
                                ),
                                labelText: "Student ID",
                                labelStyle: TextStyle(color: Colors.grey),
                                floatingLabelStyle: TextStyle(
                                  color: Color.fromARGB(255, 88, 13, 218),
                                ),
                              ),
                            ),

                            SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    88,
                                    13,
                                    218,
                                  ),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  // Validate using regex pattern: 3 digits-2 digits-4 or 5 digits
                                  RegExp regExp = RegExp(
                                    r'^\d{3}-\d{2}-\d{4,5}$',
                                  );

                                  if (regExp.hasMatch(
                                    studentIdController.text,
                                  )) {
                                    // Save login state
                                    await _authService.saveUserLogin(
                                      studentIdController.text,
                                      AuthService.USER_TYPE_STUDENT,
                                    );

                                    // Valid format, navigate to BusScheduleScreen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => BusScheduleScreen(),
                                      ),
                                    );
                                  } else {
                                    // Show error message for invalid format
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please enter a valid Student ID or Registration No',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "Login",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Admin Login Form
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            TextField(
                              controller: usernameController, // Add this line
                              decoration: InputDecoration(
                                hintText: "Enter your username",
                                hintStyle: TextStyle(color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 88, 13, 218),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 88, 13, 218),
                                  ),
                                ),
                                labelText: "Username",
                                labelStyle: TextStyle(color: Colors.grey),
                                floatingLabelStyle: TextStyle(
                                  color: Color.fromARGB(255, 88, 13, 218),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: passwordController, // Add this line
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "Enter admin password",
                                hintStyle: TextStyle(color: Colors.grey),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 88, 13, 218),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 88, 13, 218),
                                  ),
                                ),
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.grey),
                                floatingLabelStyle: TextStyle(
                                  color: Color.fromARGB(255, 88, 13, 218),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    88,
                                    13,
                                    218,
                                  ),
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  if (usernameController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please enter both username and password',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Color.fromARGB(
                                            255,
                                            88,
                                            13,
                                            218,
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  final success = await AdminService().login(
                                    usernameController.text,
                                    passwordController.text,
                                  );

                                  // Close loading dialog
                                  Navigator.of(context).pop();

                                  if (success) {
                                    // Save login state
                                    await _authService.saveUserLogin(
                                      usernameController.text,
                                      AuthService.USER_TYPE_ADMIN,
                                    );

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AdminDashboardScreen(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Invalid admin credentials',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Add space at the bottom for the footer
                      SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Static menu icon
          Positioned(
            top: 40,
            right: 40,
            child: Builder(
              builder:
                  (context) => IconButton(
                    icon: Icon(Icons.menu, color: Colors.white, size: 30),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
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
              style: GoogleFonts.inter(fontSize: 16, color: Colors.red),
            ),
            onTap: () async {
              // Close the drawer
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 88, 13, 218),
                    ),
                  );
                },
              );

              // Perform logout
              await _authService.logout();

              // Close loading dialog
              Navigator.of(context).pop();

              // Navigate to login screen
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (Route<dynamic> route) => false,
              );
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
