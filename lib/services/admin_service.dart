import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_admin_service.dart';

class AdminService {
  final FirebaseAdminService _firebaseAdminService = FirebaseAdminService();
  final String _tokenKey = 'admin_auth_token';

  // Authenticate admin using username/password (Firebase)
  Future<bool> login(String username, String password) async {
    try {
      print('Attempting to login with username: $username');

      // Try Firebase login first
      final bool firebaseLogin = await _firebaseAdminService.login(
        username,
        password,
      );
      if (firebaseLogin) {
        return true;
      }

      // Fallback to legacy credentials check for transition period
      return await _legacyLogin(username, password);
    } catch (e) {
      print('Error authenticating admin: $e');
      return false;
    }
  }

  // Email-based login (Firebase)
  Future<bool> loginWithEmail(String email, String password) async {
    return await _firebaseAdminService.loginWithEmail(email, password);
  }

  // Check if admin is logged in
  Future<bool> isLoggedIn() async {
    try {
      // Check Firebase auth first
      final bool firebaseLoggedIn = await _firebaseAdminService.isLoggedIn();
      if (firebaseLoggedIn) {
        return true;
      }

      // Fallback to legacy check
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get current admin info
  Future<Map<String, dynamic>?> getCurrentAdmin() async {
    return await _firebaseAdminService.getCurrentAdmin();
  }

  // Logout admin
  Future<void> logout() async {
    try {
      // Logout from Firebase
      await _firebaseAdminService.logout();

      // Clear legacy token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // Update admin profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    return await _firebaseAdminService.updateAdminProfile(updates);
  }

  // Change password
  Future<bool> changePassword(String newPassword) async {
    return await _firebaseAdminService.changePassword(newPassword);
  }

  // Legacy login method for backward compatibility during transition
  Future<bool> _legacyLogin(String username, String password) async {
    try {
      print('Trying legacy login method...');

      // Check against hardcoded admin credentials for transition period
      // TODO: Remove this after all admins have been migrated to Firebase
      if (username == "admin" && password == "admin123") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _generateToken(username));
        print('Legacy login successful');
        return true;
      }

      return false;
    } catch (e) {
      print('Error in legacy login: $e');
      return false;
    }
  }

  // Generate a simple token (legacy method)
  String _generateToken(String username) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$username:$timestamp';
  }
}
