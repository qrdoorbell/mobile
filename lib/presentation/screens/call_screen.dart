import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';

import '../../routing.dart';
import '../controls/video/video_call.dart';
import 'empty_screen.dart';

class CallScreen extends StatefulWidget {
  final Map<String, dynamic> callEventData;

  const CallScreen({super.key, required this.callEventData});

  @override
  State<CallScreen> createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> with RestorationMixin {
  static final logger = Logger('CallScreenState');

  final RestorableString callToken = RestorableString('');
  final RestorableString doorbellId = RestorableString('');
  final RestorableString livekitServer = RestorableString('qrdoorbell.livekit.cloud');
  final RestorableBool wasAnswered = RestorableBool(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  String? get restorationId => 'call_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(callToken, 'callToken');
    registerForRestoration(doorbellId, 'doorbellId');
    registerForRestoration(livekitServer, 'livekitServer');
    registerForRestoration(wasAnswered, 'wasAnswered');

    if (oldBucket == null) {
      callToken.value = widget.callEventData['callToken']!;
      doorbellId.value = widget.callEventData['doorbellId']!;
      livekitServer.value = widget.callEventData['livekitServer'] ?? 'qrdoorbell.livekit.cloud';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _connectToRoom(livekitServer.value, callToken.value),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              logger.shout('An error ocured while CallScreen setup', snapshot.error, snapshot.stackTrace);
              return EmptyScreen.black()
                  .withText('Failed to connect to the call')
                  .withButton('Back', () => RouteStateScope.of(context).goUri(Uri(path: '/doorbells/${doorbellId.value}')));
            }

            if (!snapshot.hasData) {
              return EmptyScreen.black().withWaitingIndicator();
            }

            if (snapshot.data == null) {
              RouteStateScope.of(context).goUri(Uri(path: '/doorbells/${doorbellId.value}'));
            }

            return VideoCall(snapshot.data!, doorbellId.value, isAnswered: wasAnswered.value);
          }),
    );
  }

  Future<Room> _connectToRoom(String? livekitServer, String accessToken) async {
    var room = Room();
    await room.connect('https://${livekitServer ?? 'qrdoorbell.livekit.cloud'}/', accessToken,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
        fastConnectOptions: FastConnectOptions(
          microphone: const TrackOption(enabled: false),
          camera: const TrackOption(enabled: false),
          screen: const TrackOption(enabled: false),
        ));

    return room;
  }
}
