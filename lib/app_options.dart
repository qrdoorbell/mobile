// ignore_for_file: constant_identifier_names
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class AppSettings extends ChangeNotifier {
  static final logger = Logger('AppSettings');
  static final AppSettings _instance = AppSettings._internal();

  factory AppSettings() => _instance;

  AppSettings._internal() {
    FirebaseRemoteConfig.instance.setDefaults({
      'GOOGLE_CLIENT_ID': const String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: ''),
      'USE_GOOGLE_ANALYTICS': const bool.fromEnvironment('USE_GOOGLE_ANALYTICS', defaultValue: false),
      'USE_CRASHALYTICS': const bool.fromEnvironment('USE_CRASHALYTICS', defaultValue: false),
      'USE_CRASHALYTICS_LOGS': const bool.fromEnvironment('USE_CRASHALYTICS_LOGS', defaultValue: false),
      'CRASHALYTICS_LOG_LEVEL': const int.fromEnvironment('CRASHALYTICS_LOG_LEVEL', defaultValue: 900),
      'QRDOORBELL_INVITE_API_URL': const String.fromEnvironment('QRDOORBELL_INVITE_API_URL', defaultValue: 'https://j.qrdoorbell.io'),
      'QRDOORBELL_API_URL': const String.fromEnvironment('QRDOORBELL_API_URL', defaultValue: 'https://api.qrdoorbell.io'),
      'HOMEKIT_ENABLED': const bool.fromEnvironment('HOMEKIT_ENABLED', defaultValue: false),
    });
  }

  static Future<void> initialize() async {
    await FirebaseRemoteConfig.instance
        .setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(minutes: 1), minimumFetchInterval: const Duration(hours: 1)));

    FirebaseRemoteConfig.instance.onConfigUpdated.listen((event) async {
      logger.info('Remote config settings updated: $event');
      if (!await FirebaseRemoteConfig.instance.activate()) {
        logger.warning('Failed to activate remote config');
        return;
      }

      _instance.notifyListeners();
    });

    try {
      await FirebaseRemoteConfig.instance.fetchAndActivate();
      logger.info('Remote config fetched and activated');
    } catch (e) {
      logger.warning('Failed to fetch and activate remote config: $e');
    }
  }

  // Google
  static String get googleClientId => FirebaseRemoteConfig.instance.getString('GOOGLE_CLIENT_ID');
  static bool get googleAnalyticsEnabled => FirebaseRemoteConfig.instance.getBool('USE_GOOGLE_ANALYTICS');

  // Google Crashalytics
  static bool get crashlyticsEnabled => FirebaseRemoteConfig.instance.getBool('USE_CRASHALYTICS');
  static bool get crashlyticsLogsEnabled => FirebaseRemoteConfig.instance.getBool('USE_CRASHALYTICS_LOGS');
  static int get crashlyticsLogLevel => FirebaseRemoteConfig.instance.getInt('CRASHALYTICS_LOG_LEVEL');

  // QRDoorbell
  static String get apiUrl => FirebaseRemoteConfig.instance.getString('QRDOORBELL_API_URL').defaultIfEmpty('https://api.qrdoorbell.io');
  static String get inviteApiUrl =>
      FirebaseRemoteConfig.instance.getString('QRDOORBELL_INVITE_API_URL').defaultIfEmpty('https://j.qrdoorbell.io');

  // Feature toggles
  static bool get homekitEnabled => FirebaseRemoteConfig.instance.getBool('HOMEKIT_ENABLED');
}

class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AppSettings? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppSettingsScope>()?.notifier;
}

extension StringExtensions on String {
  String defaultIfEmpty(String defaultValue) => isEmpty ? defaultValue : this;
}
