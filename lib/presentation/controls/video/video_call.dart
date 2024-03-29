import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../data.dart';
import '../../../services/callkit_service.dart';
import '../../../routing.dart';
import 'remote_participant_widget.dart';

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
  bool _isLocalAnswered = false;

  @override
  void initState() {
    super.initState();
    _setUpListeners();
  }

  @override
  void dispose() {
    (() async {
      await _listener.dispose();
      await widget.room.disconnect();
    })();
    super.dispose();
  }

  void _setUpListeners() => _listener
    ..on<RoomDisconnectedEvent>((event) async {
      logger.info('Room disconnected event: doorbellId=${widget.doorbellId}');
      if (event.reason != null) {
        logger.info('Room disconnected: reason => ${event.reason}');
      }
      await _endCall(context);
    })
    ..on<TrackPublishedEvent>((remoteParty) async {
      if (!_isLocalAnswered && remoteParty.participant.identity.startsWith('user-'))
        setState(() async {
          await _endCall(context);
        });
    })
    ..on<TrackUnpublishedEvent>((remoteParty) async {
      if (!_isLocalAnswered && remoteParty.participant.identity.startsWith('guest-')) await _endCall(context);
    })
    ..on<LocalTrackPublishedEvent>((remoteParty) async {
      setState(() {
        _isLocalAnswered = true;
      });
    })
    ..on<LocalTrackUnpublishedEvent>((localParty) async {
      if (_isLocalAnswered) {
        await _endCall(context);
      } else {
        await _endCallIfAlone(context);
      }
    })
    ..on<TrackMutedEvent>((mutedEvent) async {
      setState(() {});
    })
    ..on<TrackUnmutedEvent>((mutedEvent) async {
      setState(() {});
    })
    ..on<DataReceivedEvent>((event) {
      try {
        var decoded = utf8.decode(event.data);
        logger.info('Received the data: $decoded');
      } catch (_) {
        print('Failed to decode: $_');
      }
    });

  @override
  Widget build(BuildContext context) {
    RemoteParticipant? participantTrack = widget.room.participants.values.firstOrNull;
    if (participantTrack != null)
      return RemoteParticipantWidget(
          participantTrack,
          participantTrack.videoTracks.isNotEmpty
              ? participantTrack.videoTracks.where((x) => x.participant.identity.startsWith("guest-")).first.track
              : null,
          widget.doorbellId,
          _endCall);

    return Scaffold(
        backgroundColor: CupertinoColors.darkBackgroundGray,
        body: Center(
            child: SvgPicture.asset(
          'assets/logo-app-white.svg',
          width: 120,
          height: 120,
        )));
  }

  Future<void> _endCallIfAlone(BuildContext context) async {
    if (!widget.room.participants.values.any((party) => party is RemoteAudioTrack && party.identity.startsWith('guest-'))) {
      await _endCall(context);
    }
  }

  Future<void> _endCall(BuildContext context) async {
    var router = RouteStateScope.of(context);
    var dataStore = context.dataStore;
    await CallKitServiceScope.of(context)?.endCall(widget.doorbellId);
    await dataStore.doorbellEvents.reload();

    router.go('/doorbells/${widget.doorbellId}');
  }
}
