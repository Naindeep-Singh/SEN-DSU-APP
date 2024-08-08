// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBnQ8xQ7gBcISAHHObpKwpLg4IrS-u7He8',
    appId: '1:177356128094:web:f30a43aa676f0638fad9cf',
    messagingSenderId: '177356128094',
    projectId: 'sen-app-1993e',
    authDomain: 'sen-app-1993e.firebaseapp.com',
    storageBucket: 'sen-app-1993e.appspot.com',
    measurementId: 'G-S8WB7XBLPZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA7PNjlm06I8d5LtDo9J5wwa1JCV4gVOig',
    appId: '1:177356128094:android:37b6081b720b5bb3fad9cf',
    messagingSenderId: '177356128094',
    projectId: 'sen-app-1993e',
    storageBucket: 'sen-app-1993e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxFl_7gvSVBMBf3GjwVB1WlA33IVtGC6s',
    appId: '1:177356128094:ios:ae89d650077e5c02fad9cf',
    messagingSenderId: '177356128094',
    projectId: 'sen-app-1993e',
    storageBucket: 'sen-app-1993e.appspot.com',
    iosBundleId: 'com.example.senAppLatest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAxFl_7gvSVBMBf3GjwVB1WlA33IVtGC6s',
    appId: '1:177356128094:ios:ae89d650077e5c02fad9cf',
    messagingSenderId: '177356128094',
    projectId: 'sen-app-1993e',
    storageBucket: 'sen-app-1993e.appspot.com',
    iosBundleId: 'com.example.senAppLatest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBnQ8xQ7gBcISAHHObpKwpLg4IrS-u7He8',
    appId: '1:177356128094:web:2346690a9eb22b89fad9cf',
    messagingSenderId: '177356128094',
    projectId: 'sen-app-1993e',
    authDomain: 'sen-app-1993e.firebaseapp.com',
    storageBucket: 'sen-app-1993e.appspot.com',
    measurementId: 'G-9Q38KCNB5Y',
  );
}
