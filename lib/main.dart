import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:uni_links/uni_links.dart';

// import 'services/newrelic_logger.dart';
import 'presentation/controls/stickers/v1/sticker_v11_controller.dart';
import 'routing/navigation_service.dart';
import 'services/db/firebase_data_store.dart';
import 'services/callkit_service.dart';
import 'routing.dart';
import 'routing/navigator.dart';
import 'app_options.dart';
import 'data.dart';

bool _initialUriIsHandled = false;
ParsedRoute signInRoute = ParsedRoute('/login', '/login', {}, {});

final logger = Logger('main');

Future<void> main() async {
  final format = DateFormat('HH:mm:ss');
  Logger.root.level = kDebugMode ? Level.FINEST : Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${format.format(record.time)}: ${record.message}');

    if (AppSettings.crashlyticsEnabled && record.level.value >= AppSettings.crashlyticsLogLevel) {
      FirebaseCrashlytics.instance.log('[${record.level.name}] ${format.format(record.time)}: ${record.message}');
    }
  });

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await AppSettings.initialize();

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(AppSettings.crashlyticsEnabled);

  bool lastCrashlyticsEnabled = AppSettings.crashlyticsEnabled;
  AppSettings().addListener(() async {
    if (lastCrashlyticsEnabled != AppSettings.crashlyticsEnabled) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(AppSettings.crashlyticsEnabled);
      lastCrashlyticsEnabled = AppSettings.crashlyticsEnabled;
    }
  });

  FlutterError.onError = (errorDetails) {
    logger.shout("FlutterError.onError: ${errorDetails.exceptionAsString()}\nStack trace: ${errorDetails.stack?.toString()}",
        errorDetails.exception, errorDetails.stack);
    if (AppSettings.crashlyticsEnabled == true) FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.shout(
        "PlatformDispatcher.instance.onError: ${(error is Error) ? error.toString() : (error is Exception) ? error.toString() : Error.safeToString(error)}\nStack trace: ${stack.toString()}",
        error,
        stack);
    if (AppSettings.crashlyticsEnabled) FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

    return true;
  };

  FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) async {
    logger.info('Remote config settings updated: $event');
  });

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    AppleProvider(),
  ]);

  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // Stickers registration
  StickerV11Controller.register();

  runApp(const RootRestorationScope(restorationId: 'qrdoorbell', child: QRDoorbellApp()));
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  logger.info("ON BACKGROUND MESSAGE");
  logger.fine(message);
}

class QRDoorbellApp extends CupertinoApp {
  const QRDoorbellApp({super.key});

  @override
  GlobalKey<NavigatorState>? get navigatorKey => NavigationService().navigationKey;

  @override
  State<CupertinoApp> createState() => _QRDoorbellAppState();
}

class _QRDoorbellAppState extends State<QRDoorbellApp> with WidgetsBindingObserver {
  final NavigationService _navigationService = NavigationService();
  late final RouteState _routeState;
  late final TemplateRouteParser _routeParser;
  late final CallKitService _callKitService;
  late final DataStore _dataStore;
  StreamSubscription? _uriLinkStreamSubscription;

  @override
  void initState() {
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/_wait',
        '/login',
        '/login/forgot-password',
        '/doorbells',
        '/events',
        '/doorbells/new',
        '/sticker-templates/popular',
        '/sticker-templates/all',
        '/sticker-templates/:stickerTemplateId',
        '/doorbells/voip_session',
        '/doorbells/:doorbellId/qr',
        '/doorbells/:doorbellId/edit',
        '/doorbells/:doorbellId/stickers',
        '/doorbells/:doorbellId/stickers/:stickerId',
        '/doorbells/:doorbellId/stickers/templates/:stickerTemplateId',
        '/doorbells/:doorbellId/users',
        '/doorbells/:doorbellId',
        '/invite/accept/:inviteId',
        '/profile',
        '/profile/delete-account',
      ],
      guard: _guard,
      initialRoute: '/doorbells',
    );

    _routeState = RouteState(_routeParser);

    _callKitService = CallKitService(showCallScreenDelegate: _navigateToCallScreen);

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
      provisional: true,
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

    _dataStore = FirebaseDataStore(FirebaseDatabase.instance);

    if (FirebaseAuth.instance.currentUser != null) {
      _handleIncomingLinks();
      _handleInitialUri();
    }

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () async {
      await _handleActiveCallScreen();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataStoreStateScope(
        notifier: DataStoreState(dataStore: _dataStore),
        child: RouteStateScope(
            notifier: _routeState,
            child: CallKitServiceScope(
                notifier: _callKitService,
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: const [
                    DefaultCupertinoLocalizations.delegate,
                    DefaultMaterialLocalizations.delegate,
                    DefaultWidgetsLocalizations.delegate,
                  ],
                  restorationScopeId: 'qrdoorbell',
                  supportedLocales: const [
                    Locale('en', 'US'),
                    // Locale('uk', 'UA'),
                  ],
                  routerDelegate: SimpleRouterDelegate(
                    routeState: _routeState,
                    navigatorKey: _navigationService.navigationKey,
                    builder: (context) => AppNavigator(
                      navigatorKey: _navigationService.navigationKey,
                    ),
                  ),
                  routeInformationParser: _routeParser,
                  // theme: const CupertinoThemeData(
                  //   brightness: Brightness.light,
                  //   scaffoldBackgroundColor: Colors.white,
                  //   barBackgroundColor: Colors.white,
                  //   textTheme: CupertinoTextThemeData(
                  //       navLargeTitleTextStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 34)),
                  // ),
                ))));
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    logger.info('didChangeAppLifecycleState: state=${state.name}');
    if (state == AppLifecycleState.resumed) {
      _handleActiveCallScreen();
    }
  }

  @override
  void dispose() {
    _uriLinkStreamSubscription?.cancel();
    _routeState.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handleActiveCallScreen() async {
    var activeCall = await _callKitService.getActiveCall();
    if (activeCall != null) {
      _navigateToCallScreen(activeCall);
      // _navigationService.pushNamedIfNotCurrent('/doorbells/voip_session', args: activeCall);
      // _navigationService.push(_callKitService.createCallScreenRoute(activeCall));
    }
  }

  void _navigateToCallScreen(CallKeepCallData call) {
    _routeState.goUri(Uri(path: '/doorbells/voip_session', queryParameters: {'callToken': call.extra?['callToken']}), args: call.toMap());
  }

  ParsedRoute _guard(ParsedRoute from) {
    final signedIn = FirebaseAuth.instance.currentUser?.uid != null;

    if (!signedIn && from != signInRoute && from.pathTemplate != '/login/forgot-password')
      return signInRoute;
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/doorbells', '/doorbells', {}, {});
    }

    return from;
  }

  void _handleConnectionStateChanged(ConnectivityResult state) {
    logger.info("Connection state changed: state=$state");
  }

  Future<void> _handleFcmTokenChanged(String uid, String token) async {
    await _dataStore.updateFcmPushToken(token);
  }

  Future<void> _updateVoipToken(String uid) async {
    try {
      await _dataStore.updateVoipPushToken(await _callKitService.getVoipPushToken());
    } catch (e) {
      logger.shout('An error occured while getting VoIP token', e);
    }
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    FirebaseCrashlytics.instance.setUserIdentifier(user?.uid ?? "");

    if (user == null) {
      _routeState.goUri(Uri(path: '/login'));
      return;
    }

    Future.delayed(const Duration(seconds: 2), () async {
      await _updateVoipToken(user.uid);

      try {
        await _handleFcmTokenChanged(user.uid, (await FirebaseMessaging.instance.getToken())!);
      } catch (e) {
        logger.shout('An error occured while getting FCM token', e);
      }
    });
  }

  Future<void> _handleRemoteMessage(RemoteMessage? message) async {
    if (message == null) {
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
      await _routeState.goUri(Uri(path: '/doorbells/${message.data['doorbellId']}'));
    }
  }

  void _handleIncomingLinks() {
    _uriLinkStreamSubscription = uriLinkStream.listen((Uri? uri) {
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
      try {
        final uri = await getInitialUri();
        if (uri != null) {
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
