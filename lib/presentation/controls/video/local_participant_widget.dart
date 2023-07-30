import 'package:flutter/cupertino.dart';
import 'package:livekit_client/livekit_client.dart';

import 'participant_widget.dart';

class LocalParticipantWidget extends ParticipantWidget {
  @override
  final LocalParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final String doorbellId;

  const LocalParticipantWidget(
    this.participant,
    this.videoTrack,
    this.doorbellId, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LocalParticipantWidgetState();
}

class LocalParticipantWidgetState extends ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication =>
      widget.participant.videoTracks.where((element) => element.sid == widget.videoTrack?.sid).firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get firstAudioPublication => widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
}
