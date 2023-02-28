import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'app_options.dart';
import 'app_routes.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    AppleProvider(),
    GoogleProvider(clientId: GOOGLE_CLIENT_ID),
  ]);

  if (USE_AUTH_EMULATOR) {
    FirebaseAuth.instance.useAuthEmulator("localhost", 9042);
  }

  runApp(const QRDoorbellApp());
}

class QRDoorbellApp extends StatefulWidget {
  const QRDoorbellApp({super.key});

  @override
  State<StatefulWidget> createState() => _QRDoorbellAppState();
}

class _QRDoorbellAppState extends State<QRDoorbellApp> {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'QR Doorbell',
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            barBackgroundColor: Colors.white,
            // textTheme: CupertinoTextThemeData(navLargeTitleTextStyle: TextStyle(fontFamily: 'SF Pro Display', fontFamilyFallback: )),
          ),
          child: Material(
            child: child,
          ),
        );
      },
      initialRoute: Routes.login,
      routes: {
        Routes.login: (context) => LoginScreen(),
        Routes.home: (context) => MainScreen(),
      },
    );
  }
}
