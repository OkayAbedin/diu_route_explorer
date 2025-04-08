import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/route_service.dart';
import 'bus_schedule_screen.dart';
import 'admin_dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String userId;
  final String userType;

  const OnboardingScreen({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final RouteService _routeService = RouteService();
  final AuthService _authService = AuthService();

  List<String> _availableRoutes = [];
  String _selectedRoute = '';
  bool _isLoading = true;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadRouteData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadRouteData() async {
    try {
      final data = await _routeService.getRoutes();

      // Process route data
      Set<String> uniqueRoutes = {};

      for (var item in data) {
        String routeCode = item['Route'];
        String routeName = "${routeCode} - ${item['Route Name']}";

        // Skip the R1 - DSC <> Dhanmondi route
        if (!routeName.contains("R1 - DSC <> Dhanmondi")) {
          uniqueRoutes.add(routeName);
        }
      }

      setState(() {
        _availableRoutes = uniqueRoutes.toList();
        _isLoading = false;

        // Set default selected route if available
        if (_availableRoutes.isNotEmpty) {
          _selectedRoute = _availableRoutes[0];
        }
      });
    } catch (e) {
      print('Error loading route data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Save user name
      await _authService.saveUserName(_nameController.text);

      // Save default route preference
      await _authService.saveDefaultRoute(_selectedRoute);

      // Mark onboarding as completed
      await _authService.markOnboardingCompleted();

      // Navigate to appropriate screen based on user type
      if (widget.userType == AuthService.USER_TYPE_ADMIN) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BusScheduleScreen()),
        );
      }
    } catch (e) {
      print('Error completing onboarding: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's your name?",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 88, 13, 218),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Enter your name",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 88, 13, 218)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 88, 13, 218)),
            ),
            labelText: "Name",
            labelStyle: TextStyle(color: Colors.grey),
            floatingLabelStyle: TextStyle(
              color: Color.fromARGB(255, 88, 13, 218),
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildRouteStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select your default route",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 88, 13, 218),
          ),
        ),
        SizedBox(height: 20),
        Text(
          "This will be your default route in the app. You can change it later in settings.",
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 20),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _availableRoutes.isEmpty
            ? Center(
              child: Text(
                "No routes available",
                style: TextStyle(color: Colors.grey),
              ),
            )
            : Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 88, 13, 218)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedRoute.isEmpty ? null : _selectedRoute,
                  hint: Text("Select a route"),
                  items:
                      _availableRoutes.map((String route) {
                        return DropdownMenuItem<String>(
                          value: route,
                          child: Text(route),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRoute = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
        SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text(
                  "Welcome to",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "DIU ROUTE EXPLORER",
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 88, 13, 218),
                  ),
                ),
                SizedBox(height: 40),

                // Stepper content
                _currentStep == 0 ? _buildNameStep() : _buildRouteStep(),

                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          minimumSize: Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        child: Text("Back"),
                      )
                    else
                      SizedBox(width: 120),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 88, 13, 218),
                        minimumSize: Size(120, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (_currentStep < 1) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Text(
                        _currentStep < 1 ? "Next" : "Finish",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white,
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
    );
  }
}
