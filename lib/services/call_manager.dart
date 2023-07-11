import 'dart:async';

class CallManager {
  static final CallManager _instance = CallManager._internal();

  factory CallManager() => _instance;

  CallManager._internal();

  final _callInfoStreamController = StreamController<CallInfo>.broadcast();
  final _calls = <String, CallInfo>{};

  Stream<CallInfo> get callInfoStream => _callInfoStreamController.stream;

  void addCallEvent(CallEvent event) {
    _callInfoStreamController
        .add(_calls.update(event.callUuid, (value) => value.updateFromEvent(event), ifAbsent: () => CallInfo.createFromEvent(event)));

    if (event.type == CallEventType.end) {
      _calls.remove(event.callUuid);
    }
  }

  void dispose() {
    _callInfoStreamController.close();
  }
}

class CallEventType {
  static const String start = "start";
  static const String incoming = "incoming";
  static const String accept = "accept";
  static const String decline = "decline";
  static const String end = "end";
}

class CallEvent {
  final String callUuid;
  final String type;

  CallEvent(this.callUuid, this.type);
}

class StartCallEvent extends CallEvent {
  final String doorbellId;
  final String roomId;

  StartCallEvent(String callUuid, this.doorbellId, this.roomId) : super(callUuid, CallEventType.start);
}

class IncomingCallEvent extends CallEvent {
  final String callToken;

  IncomingCallEvent(String callUuid, this.callToken) : super(callUuid, CallEventType.incoming);
}

class AcceptCallEvent extends CallEvent {
  final String userId;

  AcceptCallEvent(String callUuid, this.userId) : super(callUuid, CallEventType.accept);
}

class DeclineCallEvent extends CallEvent {
  final String userId;

  DeclineCallEvent(String callUuid, this.userId) : super(callUuid, CallEventType.decline);
}

class EndCallEvent extends CallEvent {
  final String reason;

  EndCallEvent(String callUuid, this.reason) : super(callUuid, CallEventType.end);
}

class CallInfo {
  final String callUuid;
  final String doorbellId;
  final String roomId;
  final String callToken;
  final String userId;
  final String reason;
  final String callState;

  CallInfo(this.callUuid, this.doorbellId, this.roomId, this.callToken, this.userId, this.reason, this.callState);

  CallInfo updateFromEvent(CallEvent event) {
    switch (event.type) {
      case CallEventType.start:
        return CallInfo(callUuid, (event as StartCallEvent).doorbellId, event.roomId, callToken, userId, reason, event.type);
      case CallEventType.incoming:
        return CallInfo(callUuid, doorbellId, roomId, (event as IncomingCallEvent).callToken, userId, reason, event.type);
      case CallEventType.accept:
        return CallInfo(callUuid, doorbellId, roomId, callToken, (event as AcceptCallEvent).userId, reason, event.type);
      case CallEventType.decline:
        return CallInfo(callUuid, doorbellId, roomId, callToken, (event as DeclineCallEvent).userId, reason, event.type);
      case CallEventType.end:
        return CallInfo(callUuid, doorbellId, roomId, callToken, userId, (event as EndCallEvent).reason, event.type);
      default:
        return this;
    }
  }

  static CallInfo createFromEvent(CallEvent event) {
    return CallInfo(event.callUuid, "", "", "", "", "", "").updateFromEvent(event);
  }
}
