import 'package:flutter/cupertino.dart';
import 'package:livekit_client/livekit_client.dart';

import 'participant_widget.dart';

class RemoteParticipantWidget extends ParticipantWidget {
  @override
  final RemoteParticipant participant;
  @override
  final String doorbellId;

  const RemoteParticipantWidget(super.room, this.participant, this.doorbellId, super.endCall, {super.key, super.isAnswered, super.quality});

  @override
  State<StatefulWidget> createState() => RemoteParticipantWidgetState();
}

class RemoteParticipantWidgetState extends ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication => widget.participant.videoTracks.firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get firstAudioPublication => widget.participant.audioTracks.firstOrNull;
}
