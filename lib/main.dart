import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'app_options.dart';

import 'pages/home_screen.dart';
import 'pages/login_screen.dart';

// final DatabaseReference dbRef = FirebaseDatabase.instance.ref('users/ay');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (USE_AUTH_EMULATOR) {
    FirebaseAuth.instance.useAuthEmulator("localhost", 9042);
  }

  runApp(const QRDoorbellApp());
}

class QRDoorbellApp extends StatelessWidget {
  const QRDoorbellApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  // @override
  // State<StatefulWidget> createState() {
  //   return _QRDoorbellAppState();
  //   // FirebaseDatabase.instance.setPersistenceEnabled(true);

  //   // if (USE_AUTH_EMULATOR) {
  //   //   FirebaseAuth.instance.useAuthEmulator("localhost", 9042);
  //   // }

  //   // if (USE_DATABASE_EMULATOR) {
  //   //   FirebaseDatabase.instance.useDatabaseEmulator("localhost", 9041);
  //   // }

  //   // FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //   //   if (user == null) {
  //   //     print('User is currently signed out!');
  //   //   } else {
  //   //     print('User is signed in!');
  //   //   }
  //   // });

  //   // final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: "a@qx.zone", password: "1234Qwer-");
  //   // final user = userCredential.user;
  //   // print(user?.uid);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'QR Doorbell',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: LoginScreen(),
        builder: (context, child) {
          return CupertinoTheme(
            // Instead of letting Cupertino widgets auto-adapt to the Material
            // theme (which is green), this app will use a different theme
            // for Cupertino (which is blue by default).
            data: const CupertinoThemeData(),
            child: Material(child: child),
          );
        });
  }
}
