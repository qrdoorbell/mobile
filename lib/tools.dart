import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' show Response, get, post;
import 'package:logging/logging.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';

import './app_options.dart';

class HttpUtils {
  static final logger = Logger('HttpUtils');
  HttpUtils._();

  static Future<Response> securePost(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    logger.finest('Start HTTP POST: $url');

    var startTime = DateTime.now().millisecondsSinceEpoch;
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) throw AssertionError('Cannot get JWT token');

    var result = await post(url, body: body, headers: {'Authorization': 'Bearer $jwtToken'});
    var duration = DateTime.now().millisecondsSinceEpoch - startTime;

    if (AppSettings.newRelicEnabled) {
      NewrelicMobile.instance.noticeHttpTransaction(
          url.toString(), 'POST', result.statusCode, startTime, duration, 0, result.bodyBytes.sum, result.headers,
          responseBody: result.body);
    }

    logger.fine('End HTTP POST: $url, status=${result.statusCode}, duration=$duration');

    return result;
  }

  static Future<Response> secureGet(Uri url, {Map<String, String>? headers, Encoding? encoding}) async {
    logger.finest('Start HTTP GET: $url');

    var startTime = DateTime.now().millisecondsSinceEpoch;
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) throw AssertionError('Cannot get JWT token');

    var result = await get(url, headers: {'Authorization': 'Bearer $jwtToken'});
    var duration = DateTime.now().millisecondsSinceEpoch - startTime;

    if (AppSettings.newRelicEnabled) {
      NewrelicMobile.instance.noticeHttpTransaction(
          url.toString(), 'GET', result.statusCode, startTime, duration, 0, result.bodyBytes.sum, result.headers,
          responseBody: result.body);
    }

    logger.fine('End HTTP GET: $url, status=${result.statusCode}, duration=$duration');

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

class NewRelicTransactions {}
