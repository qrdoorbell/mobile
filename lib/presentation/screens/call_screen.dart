import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:qrdoorbell_mobile/routing.dart';

import '../controls/video/video_call.dart';
import 'empty_screen.dart';

extension VideoScreenExtensions on BuildContext {}

class CallScreen extends StatefulWidget {
  final String accessToken;
  final String doorbellId;

  const CallScreen({super.key, required this.accessToken, required this.doorbellId});

  @override
  State<CallScreen> createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> {
  static final logger = Logger('CallScreenState');

  Room? room;
  EventsListener<RoomEvent>? listener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    listener?.dispose();
    room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic routeData = RouteStateScope.of(context).data;
    return FutureBuilder(
        future: _connectToRoom(routeData?['livekitServer'], widget.accessToken),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.shout('An error ocured while CallScreen setup', snapshot.error, snapshot.stackTrace);
            RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}');
            return EmptyScreen.black();
          } else if (!snapshot.hasData) {
            return EmptyScreen.black().withWaitingIndicator();
          } else {
            listener = room!.createListener();
            return VideoCall(room!, listener!, widget.doorbellId);
          }
        });
  }

  Future<Room> _connectToRoom(String? livekitServer, String accessToken) async {
    room = Room();

    await room!.connect('https://${livekitServer ?? 'qrdoorbell.livekit.cloud'}/', accessToken,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          // dynacast: true,
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: false,
          ),
        ),
        fastConnectOptions: FastConnectOptions(
          microphone: const TrackOption(enabled: false),
          camera: const TrackOption(enabled: false),
        ));

    return room!;
  }
}
