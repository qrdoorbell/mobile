import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:qrdoorbell_mobile/data.dart';

import 'app_options.dart';
import 'model/db/firebase_data_store.dart';
import 'model/db/mocked_data_store.dart';
import 'routing.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'routing/navigator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(options: WebFirebaseOptions);
  }

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    AppleProvider(),
    GoogleProvider(clientId: GOOGLE_CLIENT_ID),
  ]);

  if (USE_DATABASE_EMULATOR) FirebaseDatabase.instance.useDatabaseEmulator("127.0.0.1", 9041);
  if (USE_AUTH_EMULATOR) await FirebaseAuth.instance.useAuthEmulator("127.0.0.1", 9042);

  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setLoggingEnabled(true);

  runApp(const QRDoorbellApp());
}

class QRDoorbellApp extends StatefulWidget {
  const QRDoorbellApp({super.key});

  @override
  State<StatefulWidget> createState() => _QRDoorbellAppState();
}

class _QRDoorbellAppState extends State<QRDoorbellApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/login',
        '/doorbells',
        '/events',
        '/doorbells/new',
        '/doorbells/:doorbellId',
        '/sticker-templates/popular',
        '/sticker-templates/all',
        '/doorbells/:doorbellId/stickers',
        '/doorbells/:doorbellId/stickers/:stickerId',
        '/profile',
      ],
      guard: _guard,
      initialRoute: '/doorbells',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => AppNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    FirebaseAuth.instance.authStateChanges().listen(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataStoreStateScope(
        notifier: DataStoreState(dataStore: USE_DATABASE_MOCK ? MockedDataStore() : FirebaseDataStore(db: FirebaseDatabase.instance)),
        child: RouteStateScope(
            notifier: _routeState,
            child: CupertinoApp.router(
              routerDelegate: _routerDelegate,
              routeInformationParser: _routeParser,
              theme: CupertinoThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                barBackgroundColor: Colors.white,
                textTheme: CupertinoTextThemeData(
                    navLargeTitleTextStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 34)),
              ),
            )));
  }

  @override
  void dispose() {
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = FirebaseAuth.instance.currentUser?.uid != null;
    final signInRoute = ParsedRoute('/login', '/login', {}, {});

    // Go to /signin if the user is not signed in
    if (!signedIn && from != signInRoute) {
      return signInRoute;
    }
    // Go to /doorbells if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/doorbells', '/doorbells', {}, {});
    }
    return from;
  }

  void _handleAuthStateChanged(User? user) {
    if (user == null) {
      _routeState.go('/login');
    }
  }
}
