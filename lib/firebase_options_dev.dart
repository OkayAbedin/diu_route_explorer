// Development Firebase Options - Uses emulator for local testing
// File generated for development/testing purposes
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Development [FirebaseOptions] for use with Firebase emulator.
///
/// Example:
/// ```dart
/// import 'firebase_options_dev.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptionsDev.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptionsDev {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsDev have not been configured for '
          'this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:web:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'demo-diu-route-explorer',
    authDomain: 'demo-diu-route-explorer.firebaseapp.com',
    storageBucket: 'demo-diu-route-explorer.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:android:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'demo-diu-route-explorer',
    storageBucket: 'demo-diu-route-explorer.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:ios:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'demo-diu-route-explorer',
    storageBucket: 'demo-diu-route-explorer.appspot.com',
    iosBundleId: 'com.example.diuRouteExplorer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:ios:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'demo-diu-route-explorer',
    storageBucket: 'demo-diu-route-explorer.appspot.com',
    iosBundleId: 'com.example.diuRouteExplorer',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:web:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'demo-diu-route-explorer',
    authDomain: 'demo-diu-route-explorer.firebaseapp.com',
    storageBucket: 'demo-diu-route-explorer.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:web:demo-app-id',
    messagingSenderId: '123456789',
    projectId: 'demo-diu-route-explorer',
    authDomain: 'demo-diu-route-explorer.firebaseapp.com',
    storageBucket: 'demo-diu-route-explorer.appspot.com',
  );
}
