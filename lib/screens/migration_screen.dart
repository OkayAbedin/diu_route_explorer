import 'package:flutter/material.dart';
import '../services/migration_service.dart';
import '../services/firebase_database_service.dart';

class MigrationScreen extends StatefulWidget {
  @override
  _MigrationScreenState createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  final MigrationService _migrationService = MigrationService();
  final FirebaseDatabaseService _firebaseDb = FirebaseDatabaseService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = '';
  Map<String, dynamic>? _dbStats;

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking Firebase connection...';
    });

    try {
      final success = await _migrationService.testFirebaseConnection();
      if (success) {
        final stats = await _firebaseDb.getDatabaseStats();
        setState(() {
          _dbStats = stats;
          _statusMessage =
              success
                  ? 'Firebase connected. ${stats['totalRoutes']} routes found.'
                  : 'Firebase connection failed.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Firebase connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _migrateRoutes() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Migrating routes from local database...';
    });

    try {
      final success = await _migrationService.migrateRoutesFromLocal();
      setState(() {
        _statusMessage =
            success
                ? 'Routes migrated successfully!'
                : 'Route migration failed!';
      });

      if (success) {
        await _checkFirebaseConnection(); // Refresh stats
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Route migration error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setupAdmin() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Please fill in all admin details.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Setting up admin user...';
    });

    try {
      final success = await _migrationService.setupAdminUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      );

      setState(() {
        _statusMessage =
            success
                ? 'Admin user created successfully!'
                : 'Admin setup failed!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Admin setup error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _completeMigration() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Please fill in all admin details.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting complete migration...';
    });

    try {
      final success = await _migrationService.completeMigration(
        adminEmail: _emailController.text.trim(),
        adminPassword: _passwordController.text,
        adminUsername: _usernameController.text.trim(),
      );

      setState(() {
        _statusMessage =
            success ? 'Complete migration successful!' : 'Migration failed!';
      });

      if (success) {
        await _checkFirebaseConnection(); // Refresh stats
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Migration error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Migration'),
        backgroundColor: Color.fromARGB(255, 88, 13, 218),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Migration Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (_isLoading)
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Expanded(child: Text(_statusMessage)),
                        ],
                      )
                    else
                      Text(_statusMessage),
                    if (_dbStats != null) ...[
                      SizedBox(height: 16),
                      Text(
                        'Database Statistics:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('Total Routes: ${_dbStats!['totalRoutes']}'),
                      Text(
                        'Route Groups: ${_dbStats!['routeGroups']?.length ?? 0}',
                      ),
                      Text(
                        'Schedule Types: ${_dbStats!['scheduleTypes']?.length ?? 0}',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin User Setup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Admin Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Admin Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Admin Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            Text(
              'Migration Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkFirebaseConnection,
              icon: Icon(Icons.cloud_sync),
              label: Text('Test Firebase Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _migrateRoutes,
              icon: Icon(Icons.upload),
              label: Text('Migrate Routes Only'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _setupAdmin,
              icon: Icon(Icons.admin_panel_settings),
              label: Text('Setup Admin User Only'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _completeMigration,
              icon: Icon(Icons.rocket_launch),
              label: Text('Complete Migration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 24),

            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber.shade700),
                        SizedBox(width: 8),
                        Text(
                          'Migration Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Update firebase_options.dart with your Firebase project config\n'
                      '2. Test Firebase connection first\n'
                      '3. Fill in admin user details\n'
                      '4. Run "Complete Migration" to migrate everything\n'
                      '5. Test the app with the new Firebase backend',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
