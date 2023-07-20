import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:logging/logging.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:uuid/uuid.dart';

import '../app_options.dart';
import '../routing/route_state.dart';

class CallKitService extends ChangeNotifier {
  static final logger = Logger('CallKitService');

  final RouteState routeState;
  final Map<String, String> _doorbellCalls = {}; // CallToken -> CallKit UUID

  CallKitService({required this.routeState}) {
    CallKeep.instance.onEvent.listen(_onCallKitEvent);
  }

  Future<String> getVoipPushToken() async {
    return await CallKeep.instance.getDevicePushTokenVoIP();
  }

  Future<void> endCall(doorbellId) async {
    logger.info('End Call: doorbellId=$doorbellId; callId=${_doorbellCalls[doorbellId]}');
    if (_doorbellCalls.containsKey(doorbellId)) {
      await CallKeep.instance.endCall(_doorbellCalls[doorbellId]!);
      _doorbellCalls.remove(doorbellId);

      if (NEWRELIC_APP_TOKEN.isNotEmpty)
        NewrelicMobile.instance
            .recordCustomEvent('EndCall', eventAttributes: {"doorbellId": doorbellId, "callUuid": _doorbellCalls[doorbellId]});
    }
  }

  Future<void> _onCallKitEvent(CallKeepEvent? event) async {
    logger.info("Received CallKit event: ${event?.toString()}");
    logger.fine(event);
    if (event?.type == null) return;

    if (NEWRELIC_APP_TOKEN.isNotEmpty)
      NewrelicMobile.instance.recordCustomEvent(event!.type.name, eventAttributes: _getEventMetadata(event));

    switch (event!.type) {
      case CallKeepEventType.callIncoming:
        // received an incoming call
        break;
      case CallKeepEventType.callStart:
        // started an outgoing call
        break;
      case CallKeepEventType.callAccept:
        // show screen calling in Flutter
        var callEvent = event as CallKeepCallEvent;
        if (callEvent.data.extra != null) {
          var doorbellId = callEvent.data.extra!['doorbellId'];
          var callToken = callEvent.data.extra!['callToken'];
          _doorbellCalls.putIfAbsent(doorbellId, () => callEvent.data.uuid);
          await routeState.go("/doorbells/$doorbellId/join/$callToken", data: callEvent.data.extra!);
        }
        break;
      case CallKeepEventType.callDecline:
        // declined an incoming call
        var callEvent = event as CallKeepCallEvent;
        if (callEvent.data.extra != null) {
          await endCall(callEvent.data.extra!['doorbellId']);
        }
        break;
      case CallKeepEventType.callEnded:
        var callEvent = event as CallKeepCallEvent;
        if (callEvent.data.extra != null) {
          await endCall(callEvent.data.extra!['doorbellId']);
        }
        // ended an incoming/outgoing call
        break;
      case CallKeepEventType.callTimedOut:
        // missed an incoming call
        var callEvent = event as CallKeepCallEvent;
        if (callEvent.data.extra != null) {
          await endCall(callEvent.data.extra!['doorbellId']);
        }
        break;
      case CallKeepEventType.missedCallback:
        // only Android - click action `Call back` from missed call notification
        break;
      case CallKeepEventType.holdToggled:
        // only iOS
        break;
      case CallKeepEventType.muteToggled:
        // only iOS
        break;
      case CallKeepEventType.dmtfToggled:
        // only iOS
        break;
      case CallKeepEventType.callGroupToggled:
        // only iOS
        break;
      case CallKeepEventType.audioSessionToggled:
        // only iOS
        break;
      case CallKeepEventType.devicePushTokenUpdated:
        // only iOS
        logger.log(Level.INFO, 'Got VoIP device token event: $event');
        break;
      default:
        logger.warning('CallKit event is null');
        break;
    }
  }

  Future<void> handleCallMessage(RemoteMessage message) async {
    logger.log(Level.INFO, message);
    // if ((message.data['doorbellEnabled'] ?? 1) > 0) {
    //   logger.log(Level.INFO, 'Doorbell DISABLED - skipping this message.');
    //   return;
    // }

    try {
      var callId = UuidValue(message.data['id']).toString();
      message.data['uuid'] = callId;
      _doorbellCalls[message.data['doorbellId']] = callId;

      if (NEWRELIC_APP_TOKEN.isNotEmpty) NewrelicMobile.instance.recordCustomEvent('IncomingCall', eventAttributes: message.data);

      await CallKeep.instance.displayIncomingCall(CallKeepIncomingConfig(
          uuid: callId,
          appName: 'QR Doorbell',
          callerName: message.data['doorbellName'],
          hasVideo: true,
          extra: message.data,
          handle: message.data['handle'],
          acceptText: 'Accept',
          declineText: 'Decline',
          missedCallText: 'Missed call',
          callBackText: 'Call back',
          duration: 60000,
          androidConfig: CallKeepAndroidConfig(),
          iosConfig: CallKeepIosConfig(
              audioSessionActive: true,
              audioSessionMode: AvAudioSessionMode.videoChat,
              audioSessionPreferredIOBufferDuration: 0.05,
              audioSessionPreferredSampleRate: 44100,
              supportsDTMF: false,
              supportsGrouping: false,
              supportsHolding: false,
              supportsUngrouping: false,
              iconName: 'CallKitLogo',
              handleType: CallKitHandleType.generic,
              isVideoSupported: true,
              maximumCallGroups: 1,
              maximumCallsPerCallGroup: 1,
              ringtoneFileName: 'system_ringtone_default')));
    } catch (error) {
      logger.warning("Failed to handle RemoteMessage", error);
    }
  }

  static Map<String, dynamic> _getEventMetadata(CallKeepEvent event) {
    if (event is CallKeepHoldEvent)
      return {"callUuid": event.data.uuid, "isOnHold": event.data.isOnHold};
    else if (event is CallKeepMuteEvent)
      return {"callUuid": event.data.uuid, "isOnHold": event.data.isMuted};
    else if (event is CallKeepAudioSessionEvent)
      return {"callUuid": event.data.uuid, "isActivated": event.data.isActivated};
    else
      return {"callUuid": event.data.uuid};
  }
}

class CallKitServiceScope extends InheritedNotifier<CallKitService> {
  const CallKitServiceScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static CallKitService of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CallKitServiceScope>()!.notifier!;
}
