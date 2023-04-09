import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:qrdoorbell_mobile/presentation/controls/video/participant_widget.dart';

class VideoCall extends StatefulWidget {
  final Room room;
  final EventsListener<RoomEvent> listener;

  const VideoCall(
    this.room,
    this.listener, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  List<ParticipantTrack> participantTracks = [];
  EventsListener<RoomEvent> get _listener => widget.listener;
  bool get fastConnection => widget.room.engine.fastConnectOptions != null;

  @override
  void initState() {
    super.initState();
    widget.room.addListener(_onRoomDidUpdate);
    _setUpListeners();
    _sortParticipants();
    WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
      if (!fastConnection) {
        _askPublish();
      }
    });
  }

  @override
  void dispose() {
    (() async {
      widget.room.removeListener(_onRoomDidUpdate);
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
      WidgetsBindingCompatible.instance?.addPostFrameCallback((timeStamp) => Navigator.pop(context));
    })
    ..on<LocalTrackPublishedEvent>((_) => _sortParticipants())
    ..on<LocalTrackUnpublishedEvent>((_) => _sortParticipants())
    ..on<DataReceivedEvent>((event) {
      String decoded = 'Failed to decode';
      try {
        decoded = utf8.decode(event.data);
      } catch (_) {
        print('Failed to decode: $_');
      }
      logger.log(Level.INFO, decoded);
    });

  void _askPublish() async {
    final result = await _showPublishDialog(context);
    if (result != true) return;

    // video will fail when running in ios simulator
    try {
      await widget.room.localParticipant?.setCameraEnabled(true);
    } catch (error) {
      print('could not publish video: $error');
      logger.warning(error);
    }

    try {
      await widget.room.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      print('could not publish audio: $error');
      logger.warning(error);
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _sortParticipants() {
    List<ParticipantTrack> userMediaTracks = [];
    for (var participant in widget.room.participants.values)
      for (var t in participant.videoTracks)
        userMediaTracks.add(ParticipantTrack(
          participant: participant,
          videoTrack: t.track,
        ));

    final localParticipantTracks = widget.room.localParticipant?.videoTracks;
    if (localParticipantTracks != null)
      for (var t in localParticipantTracks)
        userMediaTracks.add(ParticipantTrack(
          participant: widget.room.localParticipant!,
          videoTrack: t.track,
        ));

    setState(() {
      participantTracks = [...userMediaTracks];
    });
  }

  Future<bool?> _showPublishDialog(context) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Publish'),
          content: const Text('Would you like to publish your Camera & Mic ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('YES'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final participantTrack = participantTracks.firstWhereOrNull((e) => e.participant is RemoteParticipant);

    if (participantTrack != null)
      return RemoteParticipantWidget(participantTrack.participant as RemoteParticipant, participantTrack.videoTrack);

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
