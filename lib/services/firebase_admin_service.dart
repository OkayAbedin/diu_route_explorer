import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _adminCollection = 'admin_users';
  final String _tokenKey = 'admin_auth_token';

  // Create admin user (only call this once during setup)
  Future<bool> createAdminUser(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Create Firebase Auth user
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store admin details in Firestore
      await _firestore
          .collection(_adminCollection)
          .doc(userCredential.user!.uid)
          .set({
            'username': username,
            'email': email,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

      print('Admin user created successfully');
      return true;
    } catch (e) {
      print('Error creating admin user: $e');
      return false;
    }
  }

  // Authenticate admin using email/password
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      print('Attempting to login admin with email: $email');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Verify user is admin
      final adminDoc =
          await _firestore
              .collection(_adminCollection)
              .doc(userCredential.user!.uid)
              .get();

      if (adminDoc.exists && adminDoc.data()?['role'] == 'admin') {
        // Store local session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, userCredential.user!.uid);
        print('Admin login successful');
        return true;
      } else {
        // Sign out if not admin
        await _auth.signOut();
        print('User is not an admin');
        return false;
      }
    } catch (e) {
      print('Error authenticating admin: $e');
      return false;
    }
  }

  // Legacy username/password login (for backward compatibility)
  // This will be used during transition period
  Future<bool> login(String username, String password) async {
    try {
      print('Attempting legacy username login: $username');

      // Query Firestore for admin with matching username
      final QuerySnapshot querySnapshot =
          await _firestore
              .collection(_adminCollection)
              .where('username', isEqualTo: username)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final adminData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        final String? email = adminData['email'];

        if (email != null) {
          // Try to sign in with email and password
          return await loginWithEmail(email, password);
        }
      }

      print('Admin not found or login failed');
      return false;
    } catch (e) {
      print('Error in legacy admin login: $e');
      return false;
    }
  }

  // Check if admin is logged in
  Future<bool> isLoggedIn() async {
    try {
      // Check Firebase Auth
      final User? user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Check if user is admin in Firestore
      final adminDoc =
          await _firestore.collection(_adminCollection).doc(user.uid).get();

      final bool isAdmin =
          adminDoc.exists &&
          adminDoc.data()?['role'] == 'admin' &&
          adminDoc.data()?['isActive'] == true;

      // Also check SharedPreferences for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString(_tokenKey);

      return isAdmin && token != null;
    } catch (e) {
      print('Error checking admin login status: $e');
      return false;
    }
  }

  // Get current admin info
  Future<Map<String, dynamic>?> getCurrentAdmin() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final adminDoc =
          await _firestore.collection(_adminCollection).doc(user.uid).get();

      if (adminDoc.exists) {
        return {
          'uid': user.uid,
          'email': user.email,
          ...adminDoc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting current admin: $e');
      return null;
    }
  }

  // Logout admin
  Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print('Admin logged out successfully');
    } catch (e) {
      print('Error logging out admin: $e');
    }
  }

  // Update admin profile
  Future<bool> updateAdminProfile(Map<String, dynamic> updates) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection(_adminCollection).doc(user.uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Admin profile updated successfully');
      return true;
    } catch (e) {
      print('Error updating admin profile: $e');
      return false;
    }
  }

  // Change admin password
  Future<bool> changePassword(String newPassword) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      await user.updatePassword(newPassword);
      print('Admin password updated successfully');
      return true;
    } catch (e) {
      print('Error updating admin password: $e');
      return false;
    }
  }
}
