import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';

import '../app_options.dart';

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
    // if (_route == route) return;

    _route = route;
    notifyListeners();
  }

  Future<void> wait(Future future, Function(dynamic) destinationRouteFunc, [String? errorRoute]) =>
      go("/_wait", data: {"future": future, "destinationRouteFunc": destinationRouteFunc, "errorRoute": errorRoute});

  Future<void> go(String route, {dynamic data}) async {
    if (NEWRELIC_APP_TOKEN.isNotEmpty) NewrelicMobile.instance.recordBreadcrumb(route);

    _data = data;
    this.route = await _parser.parseRouteInformation(RouteInformation(location: route));
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
