import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
// Pages
import 'home.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
FirebaseFirestore? db;
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  db = FirebaseFirestore.instance;
  //DatabaseReference ref = FirebaseDatabase.instance.ref();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Block orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const Home());

  Permission.accessMediaLocation.status;
  Permission.camera.status;
  Permission.audio.status;
  Permission.notification.status;
  Permission.notification.request();


  WakelockPlus.enable();


}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    Permission.accessMediaLocation.status;
    Permission.camera.status;
    Permission.audio.status;
    Permission.notification.status;
    Permission.notification.request();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ors Remote Camera',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true, primaryColor: Colors.orange, splashColor: Colors.orangeAccent, cardColor: Colors.orange,
          buttonTheme: const ButtonThemeData(buttonColor: Colors.red, highlightColor: Colors.orange),
          textTheme: const TextTheme(
            bodySmall: TextStyle(fontSize: 16.0,),
            bodyMedium: TextStyle(fontSize: 20.0)
          ),

      ),
      home: const HomePage(),

    );
  }
}
