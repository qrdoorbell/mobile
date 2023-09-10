import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:pip/pip.dart';

import '../../../data.dart';
import '../../../routing.dart';
import '../../../services/callkit_service.dart';
import '../../screens/empty_screen.dart';
import 'remote_participant_widget.dart';

class VideoCall extends StatefulWidget {
  final Room room;
  final String doorbellId;
  final bool isAnswered;

  const VideoCall(this.room, this.doorbellId, {super.key, this.isAnswered = false});

  @override
  State<StatefulWidget> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  static final logger = Logger('CallKitService');
  late final EventsListener<RoomEvent> listener;

  bool _isLocalAnswered = false;
  bool _isPipSetupDone = false;

  @override
  void initState() {
    _isLocalAnswered = widget.isAnswered;
    _setUpListener();
    super.initState();
  }

  @override
  void dispose() {
    listener.dispose();
    widget.room.dispose();
    super.dispose();
  }

  void _setUpListener() {
    listener = widget.room.createListener()
      ..on<RoomDisconnectedEvent>((event) async {
        logger.info('Room disconnected event: doorbellId=${widget.doorbellId}');
        if (event.reason != null) {
          logger.info('Room disconnected: reason => ${event.reason}');
        }
        await _endCall(context);
        setState(() {});
      })
      ..on<TrackPublishedEvent>((remoteParty) async {
        if (!_isLocalAnswered &&
            (remoteParty.participant.hasAudio || remoteParty.participant.hasVideo) &&
            remoteParty.participant.identity.startsWith('user-')) {
          await _endCall(context);
        }

        setState(() {});
      })
      ..on<TrackUnpublishedEvent>((remoteParty) async {
        // if (!_isLocalAnswered && remoteParty.participant.identity.startsWith('guest-')) {
        //   await _endCall(context);
        // }
        setState(() {});
      })
      ..on<LocalTrackPublishedEvent>((remoteParty) async {
        setState(() {
          _isLocalAnswered = true;
        });
      })
      ..on<LocalTrackUnpublishedEvent>((localParty) async {
        // if (_isLocalAnswered) {
        //   await _endCall(context);
        // } else {
        // await _endCallIfAlone(context);
        // }
        setState(() {});
      })
      ..on<TrackMutedEvent>((mutedEvent) async {
        if (mutedEvent.participant is LocalParticipant) {
          // CallKitServiceScope.of(context)?.setMuted(true);
        }
        setState(() {});
      })
      ..on<TrackUnmutedEvent>((mutedEvent) async {
        if (mutedEvent.participant is LocalParticipant) {
          // CallKitServiceScope.of(context)?.setMuted(false);
        }
        setState(() {});
      })
      ..on<TrackSubscribedEvent>((event) {
        logger.info('Track subscribed event: ${event.track.sid}');

        if (event.track.isActive && event.track.kind == TrackType.VIDEO && event.participant.identity.startsWith('guest-')) {
          _setupPipView(event.participant, event.track as VideoTrack);

          setState(() {});
        }
      })
      ..on<DataReceivedEvent>((event) {
        try {
          var decoded = utf8.decode(event.data);
          logger.info('Received the data: $decoded');
        } catch (_) {
          print('Failed to decode: $_');
        }
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    var participant = widget.room.participants.values.firstWhereOrNull((x) => x.identity.startsWith('guest-'));
    if (participant != null)
      return RemoteParticipantWidget(widget.room, participant, widget.doorbellId, _endCall, isAnswered: _isLocalAnswered);

    return EmptyScreen.black().withWaitingIndicator();
  }

  Future<void> _endCallIfAlone(BuildContext context) async {
    if (!widget.room.participants.values.any((party) => party is RemoteAudioTrack && party.identity.startsWith('guest-'))) {
      await _endCall(context);
    }
  }

  Future<void> _setupPipView(RemoteParticipant participant, VideoTrack track) async {
    if (_isPipSetupDone) return;

    _isPipSetupDone = true;
    logger.info('Setting up PiP view');

    // .subscriber?.onOffer =(offer) => offer.
    // widget.room.engine.subscriber?.pc.onTrack = (event) {
    //   logger.info(
    //       '++++++++++++++++ onTrack: trackId=${event.track.id} trackKind=${event.track.kind} stream[0].id=${event.streams.firstOrNull?.id}');
    // };

    var remoteStreamId = participant.sid;
    var peerConnectionId = track.mediaStream.id;

    logger.info('Creating PiP: remoteStreamId=$remoteStreamId, peerConnectionId=$peerConnectionId');
    await Pip.createPipVideoCall(remoteStreamId: remoteStreamId, peerConnectionId: peerConnectionId);
  }

  Future<void> _endCall(BuildContext context) async {
    RouteStateScope.of(context).goUri(Uri(path: '/doorbells/${widget.doorbellId}'));

    await Future.wait([
      CallKitServiceScope.of(context)?.endCall(widget.doorbellId) ?? Future.value(),
      DataStore.of(context).doorbellEvents.reload(),
    ]);
  }
}
