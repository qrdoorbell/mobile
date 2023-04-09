import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../controls/video/video_call.dart';

extension VideoScreenExtensions on BuildContext {}

class CallScreen extends StatefulWidget {
  final String accessToken;

  const CallScreen({super.key, required this.accessToken});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
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
    return FutureBuilder(
        future: room.connect('http://10.9.9.126:7880', widget.accessToken,
            roomOptions: const RoomOptions(
              adaptiveStream: true,
              dynacast: true,
              defaultVideoPublishOptions: VideoPublishOptions(
                simulcast: false,
              ),
              defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(),
            ),
            fastConnectOptions: FastConnectOptions(
              microphone: const TrackOption(enabled: true),
              camera: const TrackOption(enabled: true),
            )),
        builder: (context, snapshot) => VideoCall(room, listener));
  }
}
