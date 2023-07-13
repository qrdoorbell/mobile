import 'package:uuid/uuid.dart';

import 'call_manager.dart';

class CallEmulatorService {
  static final CallEmulatorService _instance = CallEmulatorService._internal();

  factory CallEmulatorService() => _instance;
  CallEmulatorService._internal();

  String _callId = const Uuid().v4();
  int _i = 0;

  void setNextCallState() {
    if (_i == 0) CallManager().addCallEvent(StartCallEvent(_callId, "doorbell1_id", "room1_id"));
    if (_i == 1) CallManager().addCallEvent(IncomingCallEvent(_callId, "call_token_bla_bla_bla"));
    if (_i == 2) CallManager().addCallEvent(AcceptCallEvent(_callId, "user_me_id"));
    if (_i == 3) CallManager().addCallEvent(DeclineCallEvent(_callId, "user_me_id"));
    if (_i == 4) CallManager().addCallEvent(EndCallEvent(_callId, "ok"));

    _i++;
    if (_i == 5) {
      _i = 0;
      _callId = const Uuid().v4();
    }
  }
}
