// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBio8JlFoSMNTM8ZdcOvkpPqA3maI9Cdo8',
    appId: '1:782127433358:web:7edf9e6cb1bc97b7ff2bdf',
    messagingSenderId: '782127433358',
    projectId: 'shadow-find',
    authDomain: 'shadow-find.firebaseapp.com',
    storageBucket: 'shadow-find.firebasestorage.app',
    measurementId: 'G-FSG5JTL60F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAK5qDwDQtLIa-VF5j2F9aKt3lDgorFd3A',
    appId: '1:782127433358:android:a780dd20b5d38850ff2bdf',
    messagingSenderId: '782127433358',
    projectId: 'shadow-find',
    storageBucket: 'shadow-find.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgJ6JOYD0l60TVolYDr5zntL9dKHP_AZ4',
    appId: '1:782127433358:ios:20d89db86c6e0830ff2bdf',
    messagingSenderId: '782127433358',
    projectId: 'shadow-find',
    storageBucket: 'shadow-find.firebasestorage.app',
    iosClientId: '782127433358-fn97onchdtr7b8p436nbpinui9gtm65s.apps.googleusercontent.com',
    iosBundleId: 'com.wholito.shadowFind',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDgJ6JOYD0l60TVolYDr5zntL9dKHP_AZ4',
    appId: '1:782127433358:ios:20d89db86c6e0830ff2bdf',
    messagingSenderId: '782127433358',
    projectId: 'shadow-find',
    storageBucket: 'shadow-find.firebasestorage.app',
    iosClientId: '782127433358-fn97onchdtr7b8p436nbpinui9gtm65s.apps.googleusercontent.com',
    iosBundleId: 'com.wholito.shadowFind',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBio8JlFoSMNTM8ZdcOvkpPqA3maI9Cdo8',
    appId: '1:782127433358:web:23cfafe5289c52deff2bdf',
    messagingSenderId: '782127433358',
    projectId: 'shadow-find',
    authDomain: 'shadow-find.firebaseapp.com',
    storageBucket: 'shadow-find.firebasestorage.app',
    measurementId: 'G-39YNCCFF4W',
  );
}
