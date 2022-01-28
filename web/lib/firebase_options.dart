// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfuDTlmRtxnYyy6UNY4b31IU2adokhjB0',
    appId: '1:867330479261:web:223a6baec61b5da03c3074',
    messagingSenderId: '867330479261',
    projectId: 'master-backend-93896',
    authDomain: 'master-backend-93896.firebaseapp.com',
    storageBucket: 'master-backend-93896.appspot.com',
    measurementId: 'G-04J5DY3HPY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRxlk2vXTO0z8FYNGEyt9wNE_yWc8M5c0',
    appId: '1:867330479261:android:a2909a54354bcec03c3074',
    messagingSenderId: '867330479261',
    projectId: 'master-backend-93896',
    storageBucket: 'master-backend-93896.appspot.com',
  );
}