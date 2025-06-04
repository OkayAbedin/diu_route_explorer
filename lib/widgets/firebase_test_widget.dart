import 'package:flutter/material.dart';
import '../services/migration_service.dart';

class FirebaseConnectionTest extends StatefulWidget {
  const FirebaseConnectionTest({Key? key}) : super(key: key);

  @override
  State<FirebaseConnectionTest> createState() => _FirebaseConnectionTestState();
}

class _FirebaseConnectionTestState extends State<FirebaseConnectionTest> {
  final MigrationService _migrationService = MigrationService();
  bool _isLoading = false;
  String _result = '';

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing connection...';
    });

    try {
      final bool isConnected = await _migrationService.testFirebaseConnection();
      setState(() {
        _result =
            isConnected
                ? '✅ Firebase connection successful!'
                : '❌ Firebase connection failed';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🔥 Firebase Connection Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child:
                  _isLoading
                      ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Testing...'),
                        ],
                      )
                      : const Text('Test Firebase Connection'),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _result.contains('✅')
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _result.contains('✅') ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  _result,
                  style: TextStyle(
                    color:
                        _result.contains('✅')
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Note: This test requires proper Firebase configuration in firebase_options.dart',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
