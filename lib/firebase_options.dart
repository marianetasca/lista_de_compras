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
    apiKey: 'AIzaSyDH38Q68cbTXjjqF25s0RH-Q0VGdtnyEKA',
    appId: '1:436203219768:web:d202f86318eac8a9a1afcd',
    messagingSenderId: '436203219768',
    projectId: 'trabalho-flutter-4bdb0',
    authDomain: 'trabalho-flutter-4bdb0.firebaseapp.com',
    storageBucket: 'trabalho-flutter-4bdb0.firebasestorage.app',
    measurementId: 'G-QNXEV08QLK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqREFoYpSt9oJShfmgvh5Lf3M4r7sGiWE',
    appId: '1:436203219768:android:b27de715115dd38aa1afcd',
    messagingSenderId: '436203219768',
    projectId: 'trabalho-flutter-4bdb0',
    storageBucket: 'trabalho-flutter-4bdb0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_gcCvXvN2GmRhCvldDTSOYJsIYVZE52k',
    appId: '1:436203219768:ios:ecf6ac64e5ebe9c6a1afcd',
    messagingSenderId: '436203219768',
    projectId: 'trabalho-flutter-4bdb0',
    storageBucket: 'trabalho-flutter-4bdb0.firebasestorage.app',
    iosBundleId: 'com.example.flutterTrabalho',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD_gcCvXvN2GmRhCvldDTSOYJsIYVZE52k',
    appId: '1:436203219768:ios:ecf6ac64e5ebe9c6a1afcd',
    messagingSenderId: '436203219768',
    projectId: 'trabalho-flutter-4bdb0',
    storageBucket: 'trabalho-flutter-4bdb0.firebasestorage.app',
    iosBundleId: 'com.example.flutterTrabalho',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDH38Q68cbTXjjqF25s0RH-Q0VGdtnyEKA',
    appId: '1:436203219768:web:c58ce67aa205b93fa1afcd',
    messagingSenderId: '436203219768',
    projectId: 'trabalho-flutter-4bdb0',
    authDomain: 'trabalho-flutter-4bdb0.firebaseapp.com',
    storageBucket: 'trabalho-flutter-4bdb0.firebasestorage.app',
    measurementId: 'G-2RDEX0W3LC',
  );

}