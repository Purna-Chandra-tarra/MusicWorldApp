// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC17dXN1fsj7nfakqJnZtj63XlypF3KLvg',
    appId: '1:391332575316:web:77916e0828380ebd0715c1',
    messagingSenderId: '391332575316',
    projectId: 'cricket-f563d',
    authDomain: 'cricket-f563d.firebaseapp.com',
    storageBucket: 'cricket-f563d.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXIl7Be3fCH3HTjE-SuJG3LwyLr1Qphx8',
    appId: '1:391332575316:android:715b9683ba0e9dc50715c1',
    messagingSenderId: '391332575316',
    projectId: 'cricket-f563d',
    storageBucket: 'cricket-f563d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqlNaG2iPEkGfE87ThGgHfOzKFIfBawrI',
    appId: '1:391332575316:ios:ee66d05ecd585bb90715c1',
    messagingSenderId: '391332575316',
    projectId: 'cricket-f563d',
    storageBucket: 'cricket-f563d.appspot.com',
    iosBundleId: 'com.example.match',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqlNaG2iPEkGfE87ThGgHfOzKFIfBawrI',
    appId: '1:391332575316:ios:a1ca2295b08216710715c1',
    messagingSenderId: '391332575316',
    projectId: 'cricket-f563d',
    storageBucket: 'cricket-f563d.appspot.com',
    iosBundleId: 'com.example.match.RunnerTests',
  );
}