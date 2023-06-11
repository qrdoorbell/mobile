// ignore_for_file: constant_identifier_names
const bool USE_CRASHALYTICS = bool.fromEnvironment('USE_CRASHALYTICS', defaultValue: false);
const bool USE_CRASHALYTICS_LOGS = bool.fromEnvironment('USE_CRASHALYTICS_LOGS', defaultValue: false);
const String NEWRELIC_APP_TOKEN = String.fromEnvironment('NEWRELIC_APP_TOKEN', defaultValue: '');
const String GOOGLE_CLIENT_ID = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
const String QRDOORBELL_INVITE_API_URL = String.fromEnvironment('QRDOORBELL_INVITE_API_URL', defaultValue: 'https://j.qrdoorbell.io');
const String QRDOORBELL_API_URL = String.fromEnvironment('QRDOORBELL_API_URL', defaultValue: 'https://api.qrdoorbell.io');
