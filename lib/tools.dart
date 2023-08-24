import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' show Response, delete, get, post, put;

import 'presentation/screens/empty_screen.dart';

typedef BuildContextCallback = FutureOr<void> Function(BuildContext context);

class HttpUtils {
  static final logger = Logger('HttpUtils');
  HttpUtils._();

  static Future<Response> securePut(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    logger.finest('Start HTTP PUT: $url, body=$body');

    var startTime = DateTime.now().millisecondsSinceEpoch;
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) {
      logger.warning('Cannot get JWT token');
      throw AssertionError('Cannot get JWT token');
    }

    var result = await put(url, body: body, headers: {'Authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json'});
    var duration = DateTime.now().millisecondsSinceEpoch - startTime;

    logger.fine('End HTTP PUT: $url, status=${result.statusCode}, duration=$duration');
    return result;
  }

  static Future<Response> securePost(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    logger.finest('Start HTTP POST: $url, body=$body');

    var startTime = DateTime.now().millisecondsSinceEpoch;
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) {
      logger.warning('Cannot get JWT token');
      throw AssertionError('Cannot get JWT token');
    }

    var data = body is List<int> ? body : utf8.encode(body is String ? body : jsonEncode(body));
    var result = await post(url, body: data, headers: {'Authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json'});
    var duration = DateTime.now().millisecondsSinceEpoch - startTime;

    logger.fine('End HTTP POST: $url, status=${result.statusCode}, duration=$duration');
    return result;
  }

  static Future<Response> secureGet(Uri url, {Map<String, String>? headers, Encoding? encoding}) async {
    logger.finest('Start HTTP GET: $url');

    var startTime = DateTime.now().millisecondsSinceEpoch;
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) {
      logger.warning('Cannot get JWT token');
      throw AssertionError('Cannot get JWT token');
    }

    var result = await get(url, headers: {'Authorization': 'Bearer $jwtToken'});
    var duration = DateTime.now().millisecondsSinceEpoch - startTime;

    logger.fine('End HTTP GET: $url, status=${result.statusCode}, duration=$duration');

    return result;
  }

  static Future<Response> secureDelete(Uri url, {Map<String, String>? headers, Encoding? encoding}) async {
    logger.finest('Start HTTP DELETE: $url');

    var startTime = DateTime.now().millisecondsSinceEpoch;
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) {
      logger.warning('Cannot get JWT token');
      throw AssertionError('Cannot get JWT token');
    }

    var result = await delete(url, headers: {'Authorization': 'Bearer $jwtToken'});
    var duration = DateTime.now().millisecondsSinceEpoch - startTime;

    logger.fine('End HTTP DELETE: $url, status=${result.statusCode}, duration=$duration');

    return result;
  }
}

class PeriodicChangeNotifier extends ChangeNotifier {
  late final Timer _timer;

  PeriodicChangeNotifier(Duration duration) {
    _timer = Timer.periodic(duration, _timerCallback);
  }

  void _timerCallback(Timer timer) {
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

extension NavigatorExtensions on NavigatorState {
  FutureOr<T?> waitWithScreenThenPop<T extends Object?>(FutureOr<T?> Function() func) => waitFutureWithScreenThenPop<T>(func());

  FutureOr<T?> waitFutureWithScreenThenPop<T extends Object?>(FutureOr<T?> futureToWait) async {
    T? result;
    var route = MaterialPageRoute(builder: (context) => EmptyScreen.white().withWaitingIndicator());
    try {
      pushReplacement(route);
      result = await futureToWait;
    } finally {
      route.navigator?.pop(result);
    }

    return result;
  }
}
