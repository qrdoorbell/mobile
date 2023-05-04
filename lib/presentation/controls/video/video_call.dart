import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';

import './participant_widget.dart';
import '../../../routing.dart';

class VideoCall extends StatefulWidget {
  final Room room;
  final EventsListener<RoomEvent> listener;
  final String doorbellId;

  const VideoCall(
    this.room,
    this.listener,
    this.doorbellId, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  EventsListener<RoomEvent> get _listener => widget.listener;

  @override
  void initState() {
    super.initState();
    _setUpListeners();
  }

  @override
  void dispose() {
    (() async {
      await _listener.dispose();
      await widget.room.dispose();
    })();
    super.dispose();
  }

  void _setUpListeners() => _listener
    ..on<RoomDisconnectedEvent>((event) async {
      if (event.reason != null) {
        print('Room disconnected: reason => ${event.reason}');
      }
      FlutterCallkitIncoming.endAllCalls();
      WidgetsBindingCompatible.instance
          ?.addPostFrameCallback((timeStamp) => RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}'));
    })
    ..on<TrackPublishedEvent>((event) async {
      setState(() {});
    })
    ..on<LocalTrackPublishedEvent>((_) => {/* TODO: PUT THE LOGIC FOR ANSWERED CALL HERE */})
    ..on<DataReceivedEvent>((event) {
      String decoded = 'Failed to decode';
      try {
        decoded = utf8.decode(event.data);
      } catch (_) {
        print('Failed to decode: $_');
      }
      logger.log(Level.INFO, decoded);
    });

  @override
  Widget build(BuildContext context) {
    RemoteParticipant? participantTrack = widget.room.participants.values.firstOrNull;
    if (participantTrack != null) return RemoteParticipantWidget(participantTrack, participantTrack.videoTracks.firstOrNull?.track);

    return Scaffold(
        backgroundColor: CupertinoColors.darkBackgroundGray,
        body: Center(
            child: SvgPicture.asset(
          'assets/logo-app-white.svg',
          width: 120,
          height: 120,
        )));
  }
}
