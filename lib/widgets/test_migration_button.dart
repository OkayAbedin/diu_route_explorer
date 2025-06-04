import 'package:flutter/material.dart';
import '../services/migration_service.dart';

class TestMigrationButton extends StatefulWidget {
  @override
  _TestMigrationButtonState createState() => _TestMigrationButtonState();
}

class _TestMigrationButtonState extends State<TestMigrationButton> {
  final MigrationService _migrationService = MigrationService();
  bool _isLoading = false;
  String _status = '';

  Future<void> _testMigration() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing migration...';
    });

    try {
      // Test Firebase connection
      final connectionTest = await _migrationService.testFirebaseConnection();

      if (connectionTest) {
        setState(() {
          _status = 'Firebase connection successful!';
        });

        // Try to migrate routes
        final migrationResult =
            await _migrationService.migrateRoutesFromLocal();

        setState(() {
          _status =
              migrationResult
                  ? 'Migration completed successfully!'
                  : 'Migration failed - but Firebase is connected';
        });
      } else {
        setState(() {
          _status = 'Firebase connection failed - check configuration';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _testMigration,
          child:
              _isLoading ? CircularProgressIndicator() : Text('Test Migration'),
        ),
        if (_status.isNotEmpty)
          Padding(padding: EdgeInsets.all(8.0), child: Text(_status)),
      ],
    );
  }
}
