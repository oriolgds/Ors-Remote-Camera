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
    apiKey: 'AIzaSyD1TMLeAxdEaW7MiBUp0i3xR69nzsgpjv4',
    appId: '1:1056409113251:web:cccc6f8823fd58a526e516',
    messagingSenderId: '1056409113251',
    projectId: 'ors-camera-remote',
    authDomain: 'ors-camera-remote.firebaseapp.com',
    databaseURL: 'https://ors-camera-remote-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'ors-camera-remote.appspot.com',
    measurementId: 'G-02VM3QSCEX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNxkQ5UM-vO5jnTakvYS4DdGPi2LZu7IU',
    appId: '1:1056409113251:android:94491e7fa46cfd2a26e516',
    messagingSenderId: '1056409113251',
    projectId: 'ors-camera-remote',
    databaseURL: 'https://ors-camera-remote-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'ors-camera-remote.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDR5lPHb-lbxd7s6g35BOHvo51zvWGg-mk',
    appId: '1:1056409113251:ios:679efd5dc5c6b95d26e516',
    messagingSenderId: '1056409113251',
    projectId: 'ors-camera-remote',
    databaseURL: 'https://ors-camera-remote-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'ors-camera-remote.appspot.com',
    iosClientId: '1056409113251-841c8t22csolmvu05nmpvtm9mmnb5ocp.apps.googleusercontent.com',
    iosBundleId: 'com.orsapps.orsRemoteCamera',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDR5lPHb-lbxd7s6g35BOHvo51zvWGg-mk',
    appId: '1:1056409113251:ios:bc7ad80c522946d226e516',
    messagingSenderId: '1056409113251',
    projectId: 'ors-camera-remote',
    databaseURL: 'https://ors-camera-remote-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'ors-camera-remote.appspot.com',
    iosClientId: '1056409113251-bglp1khlj6ab6s301dmeqo5jp5on4f2d.apps.googleusercontent.com',
    iosBundleId: 'com.orsapps.orsRemoteCamera.RunnerTests',
  );
}
