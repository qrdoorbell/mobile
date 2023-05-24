import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:qrdoorbell_mobile/routing.dart';

import '../controls/video/video_call.dart';
import 'empty_screen.dart';

extension VideoScreenExtensions on BuildContext {}

class CallScreen extends StatefulWidget {
  static final logger = Logger('CallScreen');

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
  void dispose() {
    room.dispose();
    listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic routeData = RouteStateScope.of(context).data;
    logger.fine(routeData);

    room.events.on<RoomEvent>((e) {
      logger.info('Room Event: ${e.toString()}');
    });

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
              microphone: const TrackOption(enabled: false),
              camera: const TrackOption(enabled: false),
            )),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.shout('An error ocured while CallScreen setup', snapshot.error, snapshot.stackTrace);
            RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}');

            return const EmptyScreen();
          }

          if (!snapshot.hasData) {
            return const EmptyScreen();
          }

          return VideoCall(room, listener, widget.doorbellId);
        });
  }
}
