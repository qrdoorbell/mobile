import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:logging/logging.dart';
import 'package:qrdoorbell_mobile/routing/route_state.dart';
import 'package:uuid/uuid.dart';

class CallKitService {
  static final logger = Logger('CallKitService');
  static CallKitService? _instance;
  static late RouteState _routeState;

  CallKitService._(RouteState routeState) {
    _routeState = routeState;
    _instance = this;

    FlutterCallkitIncoming.onEvent.listen(_onCallKitEvent);
  }

  Future<void> _onCallKitEvent(event) async {
    logger.log(Level.INFO, event!.event);
    logger.log(Level.FINE, event);
    switch (event!.event) {
      case Event.ACTION_CALL_INCOMING:
        // TODO: received an incoming call
        break;
      case Event.ACTION_CALL_START:
        // TODO: started an outgoing call
        // TODO: show screen calling in Flutter
        break;
      case Event.ACTION_CALL_ACCEPT:
        // TODO: accepted an incoming call
        // TODO: show screen calling in Flutter
        // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        await _routeState.go("/doorbells/${event.body['extra']['doorbellId']}/ring/${event.body['extra']['callToken']}",
            data: event.body['extra']);
        break;
      case Event.ACTION_CALL_DECLINE:
        // TODO: declined an incoming call
        break;
      case Event.ACTION_CALL_ENDED:
        // TODO: ended an incoming/outgoing call
        break;
      case Event.ACTION_CALL_TIMEOUT:
        // TODO: missed an incoming call
        break;
      case Event.ACTION_CALL_CALLBACK:
        // TODO: only Android - click action `Call back` from missed call notification
        break;
      case Event.ACTION_CALL_TOGGLE_HOLD:
        // TODO: only iOS
        break;
      case Event.ACTION_CALL_TOGGLE_MUTE:
        // TODO: only iOS
        break;
      case Event.ACTION_CALL_TOGGLE_DMTF:
        // TODO: only iOS
        break;
      case Event.ACTION_CALL_TOGGLE_GROUP:
        // TODO: only iOS
        break;
      case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
        // TODO: only iOS
        break;
      case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
        // TODO: only iOS
        break;
    }
  }

  static CallKitService setRouter(RouteState routeState) {
    _instance ??= CallKitService._(routeState);
    return _instance!;
  }

  static Future<void> handleCallMessage(RemoteMessage message) async {
    logger.log(Level.INFO, message);
    if (!message.data['doorbellEnabled']) {
      logger.log(Level.INFO, 'Doorbell DISABLED - skipping this message.');
      return;
    }

    message.data['uuid'] = const Uuid().v5(Uuid.NAMESPACE_DNS, 'qrdoorbell.io');
    await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
      id: message.data['uuid'],
      nameCaller: message.data['doorbellName'],
      avatar: 'https://qrdoorbell.io/logo-100.jpg',
      appName: 'QR Doorbell',
      handle: message.data['eventId'],
      type: 1,
      duration: 60000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      textMissedCall: 'Missed call',
      textCallback: 'Call back',
      extra: message.data,
      headers: message.data,
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 2,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        isShowCallback: true,
        isShowMissedCallNotification: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
      ),
    ));
  }
}
