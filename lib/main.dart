import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';

import 'package:qrdoorbell_mobile/data.dart';

import 'app_options.dart';
import 'model/db/firebase_data_store.dart';
import 'routing.dart';
import 'routing/navigator.dart';

Future<void> main() async {
  final format = DateFormat('HH:mm:ss');
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${format.format(record.time)}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(options: WebFirebaseOptions);
  }

  FlutterError.onError = (errorDetails) {
    print("FlutterError.onError:");
    print(errorDetails);

    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  if (USE_CRASHALYTICS) {
    PlatformDispatcher.instance.onError = (error, stack) {
      print("PlatformDispatcher.instance.onError:");
      print(error);
      print(stack);

      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      AppleProvider(),
      GoogleProvider(clientId: GOOGLE_CLIENT_ID),
    ]);
  }

  if (USE_DATABASE_EMULATOR) FirebaseDatabase.instance.useDatabaseEmulator("127.0.0.1", 9041);
  if (USE_AUTH_EMULATOR) await FirebaseAuth.instance.useAuthEmulator("127.0.0.1", 9042);

  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setLoggingEnabled(true);

  runApp(const QRDoorbellApp());
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("ON BACKGROUND MESSAGE");
  print(message);
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
        '/sticker-templates/popular',
        '/sticker-templates/all',
        '/doorbells/:doorbellId/qr',
        '/doorbells/:doorbellId/edit',
        '/doorbells/:doorbellId/stickers',
        '/doorbells/:doorbellId/stickers/:stickerId',
        '/doorbells/:doorbellId',
        '/call/:accessToken',
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

    if (Platform.isIOS) {
      FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
        if (FirebaseAuth.instance.currentUser?.uid != null) await _handleFcmTokenChanged(FirebaseAuth.instance.currentUser!.uid, fcmToken);
      }).onError((err) {
        print(err);
      });
    }

    FirebaseMessaging.instance
        .requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    )
        .then((settings) async {
      print('User granted permission: ${settings.authorizationStatus}');
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    });

    FirebaseMessaging.onMessage.listen((message) async {
      print("FirebaseMessaging.onMessage");
      await _handleRemoteMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("FirebaseMessaging.onMessageOpenedApp");
      await _handleRemoteMessage(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      print('Initial message received!');
      await _handleRemoteMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseAuth.instance.authStateChanges().listen(_handleAuthStateChanged);
    Connectivity().onConnectivityChanged.listen(_handleConnectionStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataStoreStateScope(
        notifier: DataStoreState(dataStore: /*USE_DATABASE_MOCK ? MockedDataStore() :*/ FirebaseDataStore(FirebaseDatabase.instance)),
        child: RouteStateScope(
            notifier: _routeState,
            child: CupertinoApp.router(
              localizationsDelegates: const [
                DefaultCupertinoLocalizations.delegate,
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
              ],
              routerDelegate: _routerDelegate,
              routeInformationParser: _routeParser,
              theme: const CupertinoThemeData(
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

    if (!signedIn && from != signInRoute)
      return signInRoute;
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/doorbells', '/doorbells', {}, {});
    }

    return from;
  }

  void _handleConnectionStateChanged(ConnectivityResult state) {
    print("Connection state changed: state=$state");
  }

  Future<void> _handleFcmTokenChanged(String uid, String? token) async {
    token ??= await FirebaseMessaging.instance.getToken();
    await FirebaseDatabase.instance.ref("user-fcms/$uid/$token").set(true);
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    if (user == null) {
      _routeState.go('/login');
      return;
    }

    var token = await FirebaseMessaging.instance.getToken();
    await _handleFcmTokenChanged(user.uid, token);
  }

  Future<void> _handleRemoteMessage(RemoteMessage? message) async {
    if (message == null) {
      print("Main._handleRemoteMessage: Received empty RemoteMessage!");
      return;
    }

    print("Main._handleRemoteMessage: start handling RemoteMessage");
    print(message);

    if (message.data['event_type'] == 'call' && message.data['call_type'] == 'incoming' && message.data['call_token'] != null) {
      await _routeState.go("/call/incoming/${message.data['call_token']}");
    } else if (message.data['doorbellId'] != null) {
      await _routeState.go('/doorbells/${message.data['doorbellId']}');
    }
  }
}
