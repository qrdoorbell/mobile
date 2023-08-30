import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

import 'parsed_route.dart';

/// Used by [TemplateRouteParser] to guard access to routes.
typedef RouteGuard<T> = T Function(T from);

/// Parses the URI path into a [ParsedRoute].
class TemplateRouteParser extends RouteInformationParser<ParsedRoute> {
  final List<String> _pathTemplates;
  final RouteGuard<ParsedRoute>? guard;
  final ParsedRoute initialRoute;

  TemplateRouteParser({
    required List<String> allowedPaths,
    String initialRoute = '/doorbells',

    ///  [RouteGuard] used to redirect.
    this.guard,
  })  : initialRoute = ParsedRoute(initialRoute, initialRoute, {}, {}),
        _pathTemplates = [
          ...allowedPaths,
        ],
        assert(allowedPaths.contains(initialRoute));

  ParsedRoute parseRouteInformationSync(RouteInformation routeInformation) {
    final path = routeInformation.uri.path;
    final queryParams = routeInformation.uri.queryParameters;
    var parsedRoute = initialRoute;

    for (var pathTemplate in _pathTemplates) {
      final parameters = <String>[];
      var pathRegExp = pathToRegExp(pathTemplate, parameters: parameters);
      if (pathRegExp.hasMatch(path)) {
        final match = pathRegExp.matchAsPrefix(path);
        if (match == null) continue;

        final params = extract(parameters, match);
        parsedRoute = ParsedRoute(path, pathTemplate, params, queryParams);
        break;
      }
    }

    var guard = this.guard;
    if (guard != null) {
      return guard(parsedRoute);
    }

    return parsedRoute;
  }

  @override
  SynchronousFuture<ParsedRoute> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture(parseRouteInformationSync(routeInformation));

  @override
  RouteInformation restoreRouteInformation(ParsedRoute configuration) => RouteInformation(uri: configuration.toUri());
}
