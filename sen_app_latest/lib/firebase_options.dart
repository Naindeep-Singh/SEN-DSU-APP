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
    apiKey: 'AIzaSyDUQvBELu7zWTRn_r-nyFRvKMl1EuRMVgc',
    appId: '1:61650632644:web:614865e33fdeacc05a2e91',
    messagingSenderId: '61650632644',
    projectId: 'sen-app-76a99',
    authDomain: 'sen-app-76a99.firebaseapp.com',
    storageBucket: 'sen-app-76a99.appspot.com',
    measurementId: 'G-5Y0NHB2TS6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSoQx5iUsHA1UAuW6klTTgHN5OPMJ_etk',
    appId: '1:61650632644:android:96442edb271b283e5a2e91',
    messagingSenderId: '61650632644',
    projectId: 'sen-app-76a99',
    storageBucket: 'sen-app-76a99.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCG7hgFLYmdGaw-o7qaPIlff7UnAJ70h5w',
    appId: '1:61650632644:ios:b589d3d7bd098adf5a2e91',
    messagingSenderId: '61650632644',
    projectId: 'sen-app-76a99',
    storageBucket: 'sen-app-76a99.appspot.com',
    androidClientId: '61650632644-g37le7vni2u9v1gvt05vjtfe01r65pfv.apps.googleusercontent.com',
    iosClientId: '61650632644-1kbjkjhl1mqrkrrs6ahjs0ph8kp69m9s.apps.googleusercontent.com',
    iosBundleId: 'com.example.senAppLatest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCG7hgFLYmdGaw-o7qaPIlff7UnAJ70h5w',
    appId: '1:61650632644:ios:b589d3d7bd098adf5a2e91',
    messagingSenderId: '61650632644',
    projectId: 'sen-app-76a99',
    storageBucket: 'sen-app-76a99.appspot.com',
    androidClientId: '61650632644-g37le7vni2u9v1gvt05vjtfe01r65pfv.apps.googleusercontent.com',
    iosClientId: '61650632644-1kbjkjhl1mqrkrrs6ahjs0ph8kp69m9s.apps.googleusercontent.com',
    iosBundleId: 'com.example.senAppLatest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDUQvBELu7zWTRn_r-nyFRvKMl1EuRMVgc',
    appId: '1:61650632644:web:7bb7b081796d11ad5a2e91',
    messagingSenderId: '61650632644',
    projectId: 'sen-app-76a99',
    authDomain: 'sen-app-76a99.firebaseapp.com',
    storageBucket: 'sen-app-76a99.appspot.com',
    measurementId: 'G-980R2H4717',
  );

}