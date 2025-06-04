import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'bus_schedule_screen.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import 'onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController studentIdController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = Color.fromARGB(255, 88, 13, 218);
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.grey[400] : Colors.grey;
    final borderColor =
        isDarkMode ? Colors.grey[700] : Color.fromARGB(255, 88, 13, 218);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      // Removed endDrawer property
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
                    color: primaryColor,
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
                ), // Content section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(color: backgroundColor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Login Form
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          TextField(
                            controller: studentIdController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Enter your Student ID",
                              hintStyle: TextStyle(color: hintTextColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: borderColor!),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              labelText: "Student ID",
                              labelStyle: TextStyle(color: hintTextColor),
                              floatingLabelStyle: TextStyle(
                                color: isDarkMode ? Colors.white : primaryColor,
                              ),
                            ),
                          ),

                          SizedBox(height: 30),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
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

                                if (regExp.hasMatch(studentIdController.text)) {
                                  // Save login state
                                  await _authService.saveUserLogin(
                                    studentIdController.text,
                                    AuthService.USER_TYPE_STUDENT,
                                  );

                                  // Check if onboarding is completed
                                  final isOnboardingCompleted =
                                      await _authService
                                          .isOnboardingCompleted();

                                  // Navigate to appropriate screen based on onboarding status
                                  if (!isOnboardingCompleted) {
                                    // First-time user, navigate to onboarding
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => OnboardingScreen(
                                              userId: studentIdController.text,
                                              userType:
                                                  AuthService.USER_TYPE_STUDENT,
                                            ),
                                      ),
                                    );
                                  } else {
                                    // Returning user, navigate to BusScheduleScreen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => BusScheduleScreen(),
                                      ),
                                    );
                                  }
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
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () {
                // Show snackbar asking user to login first instead of opening drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please login first to access the menu',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : primaryColor,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
