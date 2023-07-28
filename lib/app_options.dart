// ignore_for_file: constant_identifier_names
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class AppSettings extends ChangeNotifier {
  static final logger = Logger('AppSettings');
  static final AppSettings _instance = AppSettings._internal();

  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  factory AppSettings() => _instance;

  AppSettings._internal() {
    _config.setDefaults({
      'GOOGLE_CLIENT_ID': const String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: ''),
      'USE_GOOGLE_ANALYTICS': const bool.fromEnvironment('USE_GOOGLE_ANALYTICS', defaultValue: false),
      'USE_CRASHALYTICS': const bool.fromEnvironment('USE_CRASHALYTICS', defaultValue: false),
      'USE_CRASHALYTICS_LOGS': const bool.fromEnvironment('USE_CRASHALYTICS_LOGS', defaultValue: false),
      'CRASHALYTICS_LOG_LEVEL': const int.fromEnvironment('CRASHALYTICS_LOG_LEVEL', defaultValue: 900),
      'USE_NEWRELIC': const bool.fromEnvironment('USE_NEWRELIC', defaultValue: false),
      'NEWRELIC_APP_TOKEN': const String.fromEnvironment('NEWRELIC_APP_TOKEN', defaultValue: ''),
      'USE_NEWRELIC_LOGS': const bool.fromEnvironment('USE_NEWRELIC_LOGS', defaultValue: false),
      'USE_NEWRELIC_LOGLEVEL': const int.fromEnvironment('USE_NEWRELIC_LOGLEVEL', defaultValue: 900),
      'USE_NEWRELIC_CRASH_LOGS': const bool.fromEnvironment('USE_NEWRELIC_CRASH_LOGS', defaultValue: false),
      'USE_NEWRELIC_TRANSACTIONS': const bool.fromEnvironment('USE_NEWRELIC_TRANSACTIONS', defaultValue: false),
      'QRDOORBELL_INVITE_API_URL': const String.fromEnvironment('QRDOORBELL_INVITE_API_URL', defaultValue: 'https://j.qrdoorbell.io'),
      'QRDOORBELL_API_URL': const String.fromEnvironment('QRDOORBELL_API_URL', defaultValue: 'https://api.qrdoorbell.io'),
      'HOMEKIT_ENABLED': const bool.fromEnvironment('HOMEKIT_ENABLED', defaultValue: false),
    });
  }

  Future<void> initialize() async {
    _config
        .setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(minutes: 1), minimumFetchInterval: const Duration(hours: 1)));

    try {
      await _config.fetchAndActivate();
      logger.info('Remote config fetched and activated');
    } catch (e) {
      logger.warning('Failed to fetch and activate remote config: $e');
    }

    _config.onConfigUpdated.listen((event) async {
      logger.info('Remote config settings updated: $event');
      await _config.activate();

      notifyListeners();
    });

    notifyListeners();
  }

  // Google
  static String get googleClientId => _instance._config.getString('GOOGLE_CLIENT_ID');
  static bool get googleAnalyticsEnabled => _instance._config.getBool('USE_GOOGLE_ANALYTICS');

  // Google Crashalytics
  static bool get crashlyticsEnabled => _instance._config.getBool('USE_CRASHALYTICS');
  static bool get crashlyticsLogsEnabled => _instance._config.getBool('USE_CRASHALYTICS_LOGS');
  static int get crashlyticsLogLevel => _instance._config.getInt('CRASHALYTICS_LOG_LEVEL');

  // NewRelic
  static String get newRelicAppToken => _instance._config.getString('NEWRELIC_APP_TOKEN');
  static bool get newRelicEnabled => _instance._config.getBool('USE_NEWRELIC') && newRelicAppToken.isNotEmpty;
  static bool get newRelicLogsEnabled => newRelicEnabled && _instance._config.getBool('USE_NEWRELIC_LOGS');
  static int get newRelicLogLevel => _instance._config.getInt('USE_NEWRELIC_LOGLEVEL');
  static bool get newRelicCrashLogsEnabled => newRelicEnabled && _instance._config.getBool('USE_NEWRELIC_CRASH_LOGS');
  static bool get newRelicTransactionsEnabled => newRelicEnabled && _instance._config.getBool('USE_NEWRELIC_TRANSACTIONS');

  // QRDoorbell
  static String get apiUrl => _instance._config.getString('QRDOORBELL_API_URL');
  static String get inviteApiUrl => _instance._config.getString('QRDOORBELL_INVITE_API_URL');

  // Feature toggles
  static bool get homekitEnabled => _instance._config.getBool('HOMEKIT_ENABLED');
}

class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AppSettings? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppSettingsScope>()?.notifier;
}
