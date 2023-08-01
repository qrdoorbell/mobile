import 'package:flutter/cupertino.dart';
import 'package:livekit_client/livekit_client.dart';

import 'participant_widget.dart';

class RemoteParticipantWidget extends ParticipantWidget {
  @override
  final RemoteParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final String doorbellId;

  const RemoteParticipantWidget(
    this.participant,
    this.videoTrack,
    this.doorbellId,
    super.endCall, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RemoteParticipantWidgetState();
}

class RemoteParticipantWidgetState extends ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication =>
      widget.participant.videoTracks.where((element) => element.sid == widget.videoTrack?.sid).firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get firstAudioPublication => widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.participant.videoTracks.firstOrNull?.track;
}
