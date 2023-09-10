import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'parsed_route.dart';
import 'route_state.dart';

class SimpleRouterDelegate extends RouterDelegate<ParsedRoute> with ChangeNotifier, PopNavigatorRouterDelegateMixin<ParsedRoute> {
  static final logger = Logger('SimpleRouterDelegate');

  final RouteState routeState;
  final WidgetBuilder builder;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  SimpleRouterDelegate({
    required this.routeState,
    required this.builder,
    required this.navigatorKey,
  }) {
    routeState.addListener(notifyListeners);
  }

  @override
  Widget build(BuildContext context) => builder(context);

  @override
  Future<void> setNewRoutePath(ParsedRoute configuration) async {
    logger.info('setNewRoutePath: path=${configuration.path} configuration=$configuration');
    routeState.route = configuration;
    return SynchronousFuture(null);
  }

  @override
  ParsedRoute get currentConfiguration => routeState.route;

  @override
  void dispose() {
    routeState.removeListener(notifyListeners);
    routeState.dispose();
    super.dispose();
  }
}
