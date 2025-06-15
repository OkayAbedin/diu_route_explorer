import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class UnifiedSplashScreen extends StatefulWidget {
  final Widget Function() onLoadingComplete;
  final Duration? minimumDuration;

  const UnifiedSplashScreen({
    super.key,
    required this.onLoadingComplete,
    this.minimumDuration,
  });

  @override
  _UnifiedSplashScreenState createState() => _UnifiedSplashScreenState();
}

class _UnifiedSplashScreenState extends State<UnifiedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isNavigated = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Reduced animation duration
    );

    // Create animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate when ready
    _navigateWhenReady();
  }

  void _navigateWhenReady() {
    // Wait for the next frame to ensure the next screen is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  void _checkAndNavigate() async {
    if (_isNavigated) return;

    // Calculate elapsed time
    final elapsed = DateTime.now().difference(_startTime);

    // Set minimum display time (shorter for better UX)
    final minimumDuration =
        widget.minimumDuration ?? Duration(milliseconds: kIsWeb ? 800 : 1200);

    if (elapsed < minimumDuration) {
      // Wait for remaining time
      final remainingTime = minimumDuration - elapsed;
      await Future.delayed(remainingTime);
    }

    if (mounted && !_isNavigated) {
      _isNavigated = true;
      final nextScreen = widget.onLoadingComplete();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromARGB(255, 88, 13, 218);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon - Optimized for performance
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/Icon.png',
                          width: 70,
                          height: 70,
                          // Add cache settings for better performance
                          cacheWidth: 70,
                          cacheHeight: 70,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.directions_bus_rounded,
                              size: 50,
                              color: primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    // App Name - Optimized text rendering
                    Text(
                      'DIU Route Explorers',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Tagline
                    Text(
                      'Navigate Your Campus Journey',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 40),
                    // Dynamic loading indicator based on state
                    _buildLoadingIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    // Simple unified loading indicator
    return SizedBox(
      width: 30,
      height: 30,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2.5,
      ),
    );
  }
}
