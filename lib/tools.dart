import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' show Response, get, post;
import 'package:logging/logging.dart';

typedef BuildContextCallback = FutureOr<void> Function(BuildContext context);

class HttpUtils {
  static final logger = Logger('HttpUtils');
  HttpUtils._();

  static Future<Response> securePost(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    logger.finest('Start HTTP POST: $url');

    var startTime = DateTime.now().millisecondsSinceEpoch;
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) {
      logger.warning('Cannot get JWT token');
      throw AssertionError('Cannot get JWT token');
    }

    var result = await post(url, body: body, headers: {'Authorization': 'Bearer $jwtToken'});
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
