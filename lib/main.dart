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
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:qrdoorbell_mobile/services/newrelic_service.dart';
import 'package:uni_links/uni_links.dart';

import 'package:qrdoorbell_mobile/data.dart';

import 'app_options.dart';
import 'model/db/firebase_data_store.dart';
import 'routing.dart';
import 'routing/navigator.dart';
import 'services/callkit_service.dart';

bool _initialUriIsHandled = false;

final logger = Logger('main');

Future<void> main() async {
  final format = DateFormat('HH:mm:ss');
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${format.format(record.time)}: ${record.message}');

    if (record.level >= Level.FINE)
      FirebaseCrashlytics.instance.log('[${record.level.toString()}] ${format.format(record.time)}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FlutterError.onError = (errorDetails) {
    logger.shout("FlutterError.onError:", errorDetails);
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  if (USE_CRASHALYTICS) {
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.shout("PlatformDispatcher.instance.onError:", error, stack);
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

  if (NEWRELIC_APP_TOKEN.isNotEmpty)
    NewrelicMobile.instance.start(NewRelicLogger.getConfig(NEWRELIC_APP_TOKEN), () {
      runApp(const QRDoorbellApp());
    });
  else
    runApp(const QRDoorbellApp());
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  logger.info("ON BACKGROUND MESSAGE");
  logger.fine(message);
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
  late final CallKitService _callKitService;
  StreamSubscription? _sub;

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
        '/doorbells/:doorbellId/ring/:accessToken',
        '/doorbells/:doorbellId/join/:accessToken',
        '/doorbells/:doorbellId',
        '/invite/accept/:inviteId',
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

    _callKitService = CallKitService(routeState: _routeState);

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      var uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _updateVoipToken(uid);
        await _handleFcmTokenChanged(uid, fcmToken);
      }
    }).onError((err) {
      logger.warning("Failed to handle FCM token refresh event", err);
    });

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
      logger.info('User granted permission: ${settings.authorizationStatus}');
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    });

    FirebaseMessaging.onMessage.listen((message) async {
      logger.info("FirebaseMessaging.onMessage");
      await _handleRemoteMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      logger.info("FirebaseMessaging.onMessageOpenedApp");
      await _handleRemoteMessage(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        logger.info('Initial message received');
        logger.fine(message);
        await _handleRemoteMessage(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseAuth.instance.authStateChanges().listen(_handleAuthStateChanged);
    Connectivity().onConnectivityChanged.listen(_handleConnectionStateChanged);

    _handleIncomingLinks();
    _handleInitialUri();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataStoreStateScope(
        notifier: DataStoreState(dataStore: /*USE_DATABASE_MOCK ? MockedDataStore() :*/ FirebaseDataStore(FirebaseDatabase.instance)),
        child: RouteStateScope(
            notifier: _routeState,
            child: CallKitServiceScope(
                notifier: _callKitService,
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
                ))));
  }

  @override
  void dispose() {
    _sub?.cancel();
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
    logger.info("Connection state changed: state=$state");
  }

  Future<void> _handleFcmTokenChanged(String uid, String? token) async {
    token ??= await FirebaseMessaging.instance.getToken();
    await FirebaseDatabase.instance.ref("user-fcms/$uid/$token").set(true);
  }

  Future<void> _updateVoipToken(String uid) async {
    var token = await _callKitService.getVoipPushToken();
    if (token.isEmpty) {
      logger.warning('Cannot get VoIP token: uid=$uid');
      return;
    }

    logger.fine('Device VoIP access token received: uid=$uid, token=$token');
    try {
      await FirebaseDatabase.instance.ref("user-voip-tokens/$uid/$token").set(true);
    } catch (err) {
      logger.warning('Cannot save VoIP token in the DB', err);
    }
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    FirebaseCrashlytics.instance.setUserIdentifier(user?.uid ?? "");

    if (user == null) {
      _routeState.go('/login');
      return;
    }

    await _updateVoipToken(user.uid);

    var token = await FirebaseMessaging.instance.getToken();
    await _handleFcmTokenChanged(user.uid, token);
  }

  Future<void> _handleRemoteMessage(RemoteMessage? message) async {
    if (message == null) {
      logger.warning("Main._handleRemoteMessage: received empty RemoteMessage!");
      return;
    }

    logger.info("Main._handleRemoteMessage: start handling RemoteMessage");
    logger.fine(message);

    if (message.data['eventType'] == 'call' &&
        message.data['callType'] == 'incoming' &&
        message.data['callToken'] != null &&
        message.data['doorbellId'] != null) {
      await _callKitService.handleCallMessage(message);
    } else if (message.data['doorbellId'] != null) {
      await _routeState.go('/doorbells/${message.data['doorbellId']}');
    }
  }

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;

      logger.info('Got incoming link: uri=$uri');
      logger.fine("Navigating to '${uri.path}'");
      _routeState.go(uri.path);
    }, onError: (Object err) {
      logger.warning('Got an error white handling incoming link', err);
    });
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      logger.info('Got incoming link during startup!');
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          logger.fine('No initial uri');
        } else {
          logger.fine('Got initial uri: $uri');
          await _routeState.go(uri.path);
        }
      } on PlatformException {
        logger.warning('Falied to get initial uri');
      } on FormatException catch (err) {
        logger.warning('Malformed initial uri', err);
      }
    }
  }
}
