import 'package:newrelic_mobile/config.dart';

class NewRelicLogger {
  static Config getConfig(String appToken) => Config(
      accessToken: appToken,

      //Android Specific
      // Optional: Enable or disable collection of event data.
      analyticsEventEnabled: true,

      // Optional: Enable or disable reporting successful HTTP requests to the MobileRequest event type.
      networkErrorRequestEnabled: true,

      // Optional: Enable or disable reporting network and HTTP request errors to the MobileRequestError event type.
      networkRequestEnabled: true,

      // Optional: Enable or disable crash reporting.
      crashReportingEnabled: true,

      // Optional: Enable or disable interaction tracing. Trace instrumentation still occurs, but no traces are harvested. This will disable default and custom interactions.
      interactionTracingEnabled: true,

      // Optional: Enable or disable capture of HTTP response bodies for HTTP error traces and MobileRequestError events.
      httpResponseBodyCaptureEnabled: true,

      // Optional: Enable or disable agent logging.
      loggingEnabled: true,

      // iOS specific
      // Optional: Enable or disable automatic instrumentation of WebViews
      webViewInstrumentation: true,

      //Optional: Enable or disable Print Statements as Analytics Events
      printStatementAsEventsEnabled: true,

      // Optional: Enable or disable automatic instrumentation of HTTP Request
      httpInstrumentationEnabled: true);
}