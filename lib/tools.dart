import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' show Response, get, post;

class HttpUtils {
  HttpUtils._();

  static Future<Response> securePost(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) throw AssertionError('Cannot get JWT token');

    return await post(url, body: body, headers: {'Authorization': 'Bearer $jwtToken'});
  }

  static Future<Response> secureGet(Uri url, {Map<String, String>? headers, Encoding? encoding}) async {
    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) throw AssertionError('Cannot get JWT token');

    return await get(url, headers: {'Authorization': 'Bearer $jwtToken'});
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
