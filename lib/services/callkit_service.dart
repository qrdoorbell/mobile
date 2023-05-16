import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:logging/logging.dart';
import 'package:qrdoorbell_mobile/routing/route_state.dart';
import 'package:uuid/uuid.dart';

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
    if (_doorbellCalls.containsKey(doorbellId)) {
      await CallKeep.instance.endCall(_doorbellCalls[doorbellId]!);
      _doorbellCalls.remove(doorbellId);
    }
  }

  Future<void> _onCallKitEvent(event) async {
    // logger.log(Level.INFO, event!.event);
    logger.log(Level.FINE, event);
    logger.log(Level.INFO, event!.type);
    switch (event!.type) {
      case CallKeepEventType.callIncoming:
        // TODO: received an incoming call
        break;
      case CallKeepEventType.callStart:
        // TODO: started an outgoing call
        // TODO: show screen calling in Flutter
        break;
      case CallKeepEventType.callAccept:
        // TODO: accepted an incoming call
        // TODO: show screen calling in Flutter
        var callEvent = event as CallKeepCallEvent;
        if (callEvent.data.extra != null) {
          var doorbellId = callEvent.data.extra!['doorbellId'];
          var callToken = callEvent.data.extra!['callToken'];
          await routeState.go("/doorbells/$doorbellId/ring/$callToken", data: callEvent.data.extra!);
        }
        break;
      case CallKeepEventType.callDecline:
        // TODO: declined an incoming call
        break;
      case CallKeepEventType.callEnded:
        // TODO: ended an incoming/outgoing call
        break;
      case CallKeepEventType.callTimedOut:
        // TODO: missed an incoming call
        break;
      case CallKeepEventType.missedCallback:
        // TODO: only Android - click action `Call back` from missed call notification
        break;
      case CallKeepEventType.holdToggled:
        // TODO: only iOS
        break;
      case CallKeepEventType.muteToggled:
        // TODO: only iOS
        break;
      case CallKeepEventType.dmtfToggled:
        // TODO: only iOS
        break;
      case CallKeepEventType.callGroupToggled:
        // TODO: only iOS
        break;
      case CallKeepEventType.audioSessionToggled:
        // TODO: only iOS
        break;
      case CallKeepEventType.devicePushTokenUpdated:
        // TODO: only iOS
        logger.log(Level.INFO, 'Got VoIP device token event: $event');
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

      await CallKeep.instance.displayIncomingCall(CallKeepIncomingConfig(
          uuid: callId,
          appName: 'QR Doorbell',
          avatar: 'https://qrdoorbell.io/logo-100.jpg',
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
              iconName: 'CallKitLogo',
              handleType: CallKitHandleType.generic,
              isVideoSupported: true,
              ringtoneFileName: 'system_ringtone_default')));

      // await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
      //   id: callUuid,
      //   nameCaller: message.data['doorbellName'],
      //   avatar: 'https://qrdoorbell.io/logo-100.jpg',
      //   appName: 'QR Doorbell',
      //   handle: message.data['doorbellName'],
      //   type: 1,
      //   duration: 60000,
      //   textAccept: 'Accept',
      //   textDecline: 'Decline',
      //   textMissedCall: 'Missed call',
      //   textCallback: 'Call back',
      //   extra: message.data,
      //   headers: message.data,
      //   ios: IOSParams(
      //     iconName: 'CallKitLogo',
      //     handleType: 'generic',
      //     supportsVideo: true,
      //     maximumCallGroups: 2,
      //     maximumCallsPerCallGroup: 2,
      //     audioSessionMode: 'default',
      //     audioSessionActive: true,
      //     audioSessionPreferredSampleRate: 44100.0,
      //     audioSessionPreferredIOBufferDuration: 0.005,
      //     supportsDTMF: false,
      //     supportsHolding: false,
      //     supportsGrouping: false,
      //     supportsUngrouping: false,
      //     ringtonePath: 'system_ringtone_default',
      //   ),
      //   android: const AndroidParams(
      //     isCustomNotification: true,
      //     isShowLogo: true,
      //     isShowCallback: true,
      //     isShowMissedCallNotification: true,
      //     ringtonePath: 'system_ringtone_default',
      //     backgroundColor: '#0955fa',
      //     backgroundUrl: 'assets/test.png',
      //     actionColor: '#4CAF50',
      //   ),
      // ));
    } catch (error) {
      logger.warning("Failed to handle RemoteMessage", error);
    }
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
