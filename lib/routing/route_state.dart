import 'dart:async';

import 'package:flutter/widgets.dart';

import 'parsed_route.dart';
import 'parser.dart';

class RouteState extends ChangeNotifier {
  final TemplateRouteParser _parser;
  ParsedRoute _route;
  dynamic _data;

  RouteState(this._parser) : _route = _parser.initialRoute;

  ParsedRoute get route => _route;
  dynamic get data => _data;

  set route(ParsedRoute route) {
    if (_route == route) return;

    _route = route;
    notifyListeners();
  }

  Future<void> wait(Future future,
          {Function(dynamic)? destinationRouteFunc,
          String? destinationRoute,
          String? errorRoute,
          Duration timeout = const Duration(seconds: 30)}) =>
      go("/_wait", data: {
        "future": future,
        "destinationRouteFunc": destinationRouteFunc,
        "destinationRoute": destinationRoute,
        "errorRoute": errorRoute,
        "timeout": timeout
      });

  @Deprecated('Use goUri instead')
  Future<void> go(String uri, {dynamic data}) async {
    _data = data;
    route = _parser.parseRouteInformationSync(RouteInformation(uri: Uri.parse(uri)));
  }

  Future<void> goUri(Uri uri, {Object? args}) async {
    route = _parser.parseRouteInformationSync(RouteInformation(uri: uri, state: args));
  }

  Route parseRouteSync(String route) {
    return _parser.parseRouteInformationSync(RouteInformation(uri: Uri.parse(route)));
  }

  Future<Route> parseRoute(String route) async {
    return await _parser.parseRouteInformation(RouteInformation(uri: Uri.parse(route)));
  }
}

class RouteStateScope extends InheritedNotifier<RouteState> {
  const RouteStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static RouteState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<RouteStateScope>()!.notifier!;
}
