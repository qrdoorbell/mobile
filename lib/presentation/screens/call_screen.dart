import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:qrdoorbell_mobile/routing.dart';

import '../controls/video/video_call.dart';

extension VideoScreenExtensions on BuildContext {}

class CallScreen extends StatefulWidget {
  final String accessToken;
  final String doorbellId;

  const CallScreen({super.key, required this.accessToken, required this.doorbellId});

  @override
  State<CallScreen> createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> {
  late final Room room;
  late final EventsListener<RoomEvent> listener;

  @override
  void initState() {
    super.initState();
    room = Room();
    listener = room.createListener();
  }

  @override
  Widget build(BuildContext context) {
    dynamic routeData = RouteStateScope.of(context).data;
    logger.fine(routeData);
    return FutureBuilder(
        future: room.connect(
            'https://${(routeData != null ? routeData['livekitServer'] : null) ?? 'qrdoorbell.livekit.cloud'}/', widget.accessToken,
            roomOptions: const RoomOptions(
              adaptiveStream: true,
              dynacast: true,
              defaultVideoPublishOptions: VideoPublishOptions(
                simulcast: false,
              ),
            ),
            fastConnectOptions: FastConnectOptions(
              microphone: const TrackOption(enabled: true),
              camera: const TrackOption(enabled: false),
            )),
        builder: (context, snapshot) => VideoCall(room, listener, widget.doorbellId));
  }
}
