import 'package:newrelic_mobile/config.dart';

import '../app_options.dart';

class NewRelicLogger {
  static Config get config => Config(
      accessToken: AppSettings.newRelicAppToken,

      //Android Specific
      // Optional: Enable or disable collection of event data.
      analyticsEventEnabled: AppSettings.newRelicEnabled,

      // Optional: Enable or disable reporting successful HTTP requests to the MobileRequest event type.
      networkErrorRequestEnabled: AppSettings.newRelicEnabled,

      // Optional: Enable or disable reporting network and HTTP request errors to the MobileRequestError event type.
      networkRequestEnabled: AppSettings.newRelicEnabled,

      // Optional: Enable or disable crash reporting.
      crashReportingEnabled: AppSettings.newRelicCrashLogsEnabled,

      // Optional: Enable or disable interaction tracing. Trace instrumentation still occurs, but no traces are harvested. This will disable default and custom interactions.
      interactionTracingEnabled: AppSettings.newRelicEnabled,

      // Optional: Enable or disable capture of HTTP response bodies for HTTP error traces and MobileRequestError events.
      httpResponseBodyCaptureEnabled: AppSettings.newRelicEnabled,

      // Optional: Enable or disable agent logging.
      loggingEnabled: AppSettings.newRelicLogsEnabled,

      // iOS specific
      // Optional: Enable or disable automatic instrumentation of WebViews
      webViewInstrumentation: AppSettings.newRelicEnabled,

      //Optional: Enable or disable Print Statements as Analytics Events
      printStatementAsEventsEnabled: AppSettings.newRelicEnabled,

      // Optional: Enable or disable automatic instrumentation of HTTP Request
      httpInstrumentationEnabled: AppSettings.newRelicEnabled);
}
