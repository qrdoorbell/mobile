import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

class CallKitService extends ChangeNotifier {
  static final logger = Logger('CallKitService');

  final void Function(CallKeepCallData call) showCallScreenDelegate;
  final Map<String, String> _doorbellCalls = {}; // CallToken -> CallKit UUID

  CallKitService({required this.showCallScreenDelegate}) {
    CallKeep.instance.onEvent.listen(_onCallKitEvent);
  }

  Future<CallKeepCallData?> getActiveCall() async {
    var calls = await CallKeep.instance.activeCalls();

    CallKeepCallData? activeCall;
    for (var call in calls) {
      if (call.extra != null && call.extra!['doorbellId'] != null) {
        _doorbellCalls.putIfAbsent(call.extra!['doorbellId'], () => call.uuid);

        if (call.isAccepted) activeCall = call;
      }
    }

    return activeCall;
  }

  Future<String> getVoipPushToken() async {
    return await CallKeep.instance.getDevicePushTokenVoIP();
  }

  Future<void> endCall(doorbellId) async {
    logger.info('End Call: doorbellId=$doorbellId; callId=${_doorbellCalls[doorbellId]}');
    if (_doorbellCalls.containsKey(doorbellId)) {
      try {
        await CallKeep.instance.endCall(_doorbellCalls[doorbellId]!);
      } catch (e) {
        logger.warning('Failed to end call', e);
      }
      _doorbellCalls.remove(doorbellId);
    }
  }

  // PageRoute createCallScreenRoute(CallKeepCallData call) {
  //   return CupertinoPageRoute(
  //       settings: RouteSettings(name: '/voip_session', arguments: call.extra!),
  //       builder: (context) => CallScreen(
  //           callEventData: Map.fromEntries(call.extra!.entries.map((e) => MapEntry<String, String>(e.key, e.value?.toString() ?? '')))));
  // }

  Future<void> _onCallKitEvent(CallKeepEvent? event) async {
    if (event == null) return;

    logger.info("Received CallKit event: type=${event.type.toString()}, event=${event.data.toString()}");
    switch (event.type) {
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
          var doorbellId = callEvent.data.extra?['doorbellId'];
          var callToken = callEvent.data.extra?['callToken'];

          if (doorbellId == null || callToken == null) {
            logger.warning('Cannot find doorbellId or callToken in CallKit extra data');
            return;
          }

          _doorbellCalls.putIfAbsent(doorbellId, () => callEvent.data.uuid);
          showCallScreenDelegate(callEvent.data);
          // navigationService.pushNamedIfNotCurrent('/doorbells/voip_session', args: callEvent.data);
        }
        break;
      case CallKeepEventType.callDecline:
        // declined an incoming call
        var callEvent = event as CallKeepCallEvent;
        if (callEvent.data.extra != null) {
          await endCall(callEvent.data.extra?['doorbellId']);
        }
        break;
      case CallKeepEventType.callEnded:
        var callEvent = event as CallKeepCallEvent;
        if (callEvent.data.extra != null) {
          await endCall(callEvent.data.extra?['doorbellId']);
        }
        // ended an incoming/outgoing call
        break;
      case CallKeepEventType.callTimedOut:
        // missed an incoming call
        var callEvent = event as CallKeepCallEvent;
        if (callEvent.data.extra != null) {
          await endCall(callEvent.data.extra?['doorbellId']);
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
        break;
      default:
        logger.warning('Unknown CallKit event type: ${event.type}');
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
              audioSessionPreferredIOBufferDuration: 0.05,
              audioSessionPreferredSampleRate: 44100,
              supportsDTMF: false,
              supportsGrouping: false,
              supportsHolding: true,
              supportsUngrouping: false,
              iconName: 'CallKitLogo',
              handleType: CallKitHandleType.generic,
              isVideoSupported: true,
              maximumCallGroups: 2,
              maximumCallsPerCallGroup: 1,
              ringtoneFileName: 'system_ringtone_default')));
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

  static CallKitService? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CallKitServiceScope>()?.notifier;
}
