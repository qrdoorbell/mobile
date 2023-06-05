// ignore_for_file: constant_identifier_names
const bool USE_AUTH_EMULATOR = bool.fromEnvironment('USE_AUTH_EMULATOR', defaultValue: false);
const bool USE_DATABASE_MOCK = bool.fromEnvironment('USE_DATABASE_MOCK', defaultValue: false);
const bool USE_DATABASE_EMULATOR = bool.fromEnvironment('USE_DATABASE_EMULATOR', defaultValue: false);
const bool USE_CRASHALYTICS = bool.fromEnvironment('USE_CRASHALYTICS', defaultValue: false);
const String NEWRELIC_APP_TOKEN = String.fromEnvironment('NEWRELIC_APP_TOKEN', defaultValue: '');
const String GOOGLE_CLIENT_ID = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
