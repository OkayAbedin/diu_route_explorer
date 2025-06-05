import 'package:flutter/foundation.dart';

class WebConfig {
  static const bool isOptimizedBuild = kReleaseMode;

  // Performance configurations for web
  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Cache configurations
  static const Duration cacheExpiry = Duration(hours: 6);
  static const int maxCacheSize = 50; // Maximum number of cached items

  // Network configurations
  static const Duration networkTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;

  // UI configurations
  static const bool enableAnimations = true;
  static const bool enableHapticFeedback = false; // Disable for web
  static const bool enableSounds = false; // Disable for web

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = !kIsWeb;
  static const bool enableLocationServices = !kIsWeb;
}
