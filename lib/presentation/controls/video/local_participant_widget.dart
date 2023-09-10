import 'package:flutter/cupertino.dart';
import 'package:livekit_client/livekit_client.dart';

import 'participant_widget.dart';

class LocalParticipantWidget extends ParticipantWidget {
  @override
  final LocalParticipant participant;
  @override
  final String doorbellId;

  const LocalParticipantWidget(super.room, this.participant, this.doorbellId, super.endCall, {super.key, super.isAnswered, super.quality});

  @override
  State<StatefulWidget> createState() => LocalParticipantWidgetState();
}

class LocalParticipantWidgetState extends ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication => widget.participant.videoTracks.firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get firstAudioPublication => widget.participant.audioTracks.firstOrNull;
}
