import 'dart:convert';
import 'package:flutter/services.dart';
import 'firebase_database_service.dart';
import 'firebase_admin_service.dart';

class MigrationService {
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();
  final FirebaseAdminService _firebaseAdmin = FirebaseAdminService();

  // Migrate routes from local JSON file to Firebase
  Future<bool> migrateRoutesFromLocal() async {
    try {
      print('Starting migration from local database.json...');

      // Load data from local database.json file
      final String jsonString = await rootBundle.loadString('database.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      final List<Map<String, dynamic>> routes =
          jsonData.cast<Map<String, dynamic>>();

      print('Loaded ${routes.length} routes from local file');

      // Migrate to Firebase
      final bool success = await _firebaseDb.migrateFromJsonBin(routes);

      if (success) {
        print('✅ Routes migration completed successfully!');
        return true;
      } else {
        print('❌ Routes migration failed');
        return false;
      }
    } catch (e) {
      print('❌ Error during routes migration: $e');
      return false;
    }
  }

  // Setup initial admin user in Firebase
  Future<bool> setupAdminUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      print('Setting up admin user in Firebase...');

      final bool success = await _firebaseAdmin.createAdminUser(
        email,
        password,
        username,
      );

      if (success) {
        print('✅ Admin user setup completed successfully!');
        print('Admin can now login with:');
        print('Email: $email');
        print('Username: $username');
        return true;
      } else {
        print('❌ Admin user setup failed');
        return false;
      }
    } catch (e) {
      print('❌ Error during admin setup: $e');
      return false;
    }
  }

  // Complete migration process
  Future<bool> completeMigration({
    required String adminEmail,
    required String adminPassword,
    required String adminUsername,
  }) async {
    try {
      print('🚀 Starting complete migration process...');

      // Step 1: Migrate routes
      print('\n📊 Step 1: Migrating routes...');
      final bool routesMigrated = await migrateRoutesFromLocal();
      if (!routesMigrated) {
        print('❌ Routes migration failed. Stopping process.');
        return false;
      }

      // Step 2: Setup admin user
      print('\n👤 Step 2: Setting up admin user...');
      final bool adminSetup = await setupAdminUser(
        email: adminEmail,
        password: adminPassword,
        username: adminUsername,
      );
      if (!adminSetup) {
        print('❌ Admin setup failed. Routes migrated but admin not created.');
        return false;
      }

      // Step 3: Verify migration
      print('\n✅ Step 3: Verifying migration...');
      final stats = await _firebaseDb.getDatabaseStats();
      print('Migration Statistics:');
      print('- Total routes: ${stats['totalRoutes']}');
      print('- Route groups: ${stats['routeGroups']}');
      print('- Schedule types: ${stats['scheduleTypes']}');

      print('\n🎉 Migration completed successfully!');
      print('\n📋 Next steps:');
      print('1. Update your Firebase configuration in firebase_options.dart');
      print('2. Test the admin login functionality');
      print('3. Verify routes are displaying correctly');
      print('4. Remove old JSONBin service files');

      return true;
    } catch (e) {
      print('❌ Error during complete migration: $e');
      return false;
    }
  }

  // Rollback migration (restore from backup)
  Future<bool> rollbackMigration(List<Map<String, dynamic>> backupData) async {
    try {
      print('🔄 Rolling back migration...');

      final bool success = await _firebaseDb.updateDatabase(backupData);

      if (success) {
        print('✅ Rollback completed successfully!');
        return true;
      } else {
        print('❌ Rollback failed');
        return false;
      }
    } catch (e) {
      print('❌ Error during rollback: $e');
      return false;
    }
  }

  // Test Firebase connection
  Future<bool> testFirebaseConnection() async {
    try {
      print('🔍 Testing Firebase connection...');

      // Test Firestore connection
      final stats = await _firebaseDb.getDatabaseStats();
      print('✅ Firestore connection successful');
      print('Current database has ${stats['totalRoutes']} routes');

      return true;
    } catch (e) {
      print('❌ Firebase connection test failed: $e');
      return false;
    }
  }
}
