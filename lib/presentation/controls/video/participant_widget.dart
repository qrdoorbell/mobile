import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:qrdoorbell_mobile/routing.dart';
import 'package:qrdoorbell_mobile/services/callkit_service.dart';

import '../../screens/call_screen.dart';

class ParticipantTrack {
  ParticipantTrack({required this.participant, required this.videoTrack});
  VideoTrack? videoTrack;
  Participant participant;
}

abstract class ParticipantWidget extends StatefulWidget {
  abstract final Participant participant;
  abstract final VideoTrack? videoTrack;
  abstract final String doorbellId;
  final VideoQuality quality;

  const ParticipantWidget({
    this.quality = VideoQuality.MEDIUM,
    Key? key,
  }) : super(key: key);
}

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
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

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
    this.doorbellId, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget> extends State<T> {
  Timer? timer;
  bool _visible = true;
  VideoTrack? get activeVideoTrack;
  TrackPublication? get videoPublication;
  TrackPublication? get firstAudioPublication;
  Duration? callDuration;

  @override
  void initState() {
    callDuration = Duration.zero;
    timer = Timer(const Duration(seconds: 1), () {
      if (callDuration != null)
        setState(() {
          callDuration = (callDuration ?? Duration.zero) + const Duration(seconds: 1);
        });
    });

    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    timer?.cancel();
    widget.participant.removeListener(_onParticipantChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    oldWidget.participant.removeListener(_onParticipantChanged);
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
    super.didUpdateWidget(oldWidget);
  }

  void _onParticipantChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    var room = context.findAncestorStateOfType<CallScreenState>()?.room;

    return Scaffold(
        backgroundColor: CupertinoColors.darkBackgroundGray,
        body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.topCenter,
              children: [
                InkWell(
                  onTap: () => setState(() => _visible = !_visible),
                  child: activeVideoTrack != null
                      ? VideoTrackRenderer(
                          activeVideoTrack!,
                          fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : const Text(''),
                ),
                Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 140)),
                    Text(
                      this._getStateText(room),
                      style: const TextStyle(color: Colors.white, fontSize: 32),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: callDuration != null
                            ? Text(_printDuration(callDuration!),
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                ))
                            : Container()),
                    const Spacer(),
                    Row(
                      children: [
                        const Spacer(),
                        CupertinoButton(
                            color: CupertinoColors.white.withOpacity(0.3),
                            borderRadius: const BorderRadius.all(Radius.circular(55)),
                            padding: const EdgeInsets.all(20),
                            child: Icon(
                              room?.localParticipant?.isMuted == false ? CupertinoIcons.mic_solid : CupertinoIcons.mic_slash_fill,
                              color: CupertinoColors.white,
                              size: 36,
                            ),
                            onPressed: () => setState(() {
                                  room?.localParticipant?.setMicrophoneEnabled(!(room.localParticipant?.isMuted ?? false));
                                })),
                        const Spacer(),
                        CupertinoButton(
                            color: CupertinoColors.white.withOpacity(0.3),
                            borderRadius: const BorderRadius.all(Radius.circular(55)),
                            padding: const EdgeInsets.all(20),
                            child: Icon(
                              room?.localParticipant?.hasVideo == true ? CupertinoIcons.video_camera_solid : CupertinoIcons.video_camera,
                              color: CupertinoColors.white,
                              size: 36,
                            ),
                            onPressed: () => setState(() {
                                  room?.localParticipant?.setCameraEnabled(!(room.localParticipant?.hasVideo ?? false));
                                })),
                        const Spacer(),
                        CupertinoButton(
                            color: CupertinoColors.white.withOpacity(0.6),
                            borderRadius: const BorderRadius.all(Radius.circular(55)),
                            padding: const EdgeInsets.all(20),
                            child: const Icon(
                              CupertinoIcons.speaker_3_fill,
                              color: CupertinoColors.white,
                              size: 36,
                            ),
                            onPressed: () => setState(() {
                                  room?.setSpeakerOn(!(room.speakerOn ?? false));
                                })),
                        const Spacer(),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(top: 60)),
                    CupertinoButton(
                        color: CupertinoColors.destructiveRed,
                        borderRadius: const BorderRadius.all(Radius.circular(55)),
                        padding: const EdgeInsets.all(20),
                        child: const Icon(
                          CupertinoIcons.phone_down_fill,
                          color: CupertinoColors.white,
                          size: 36,
                        ),
                        onPressed: () async {
                          var router = RouteStateScope.of(context);
                          await CallKitServiceScope.of(context).endCall(widget.doorbellId);
                          await widget.participant.unpublishAllTracks();
                          await widget.participant.dispose();
                          await router.go('/doorbells');
                        }),
                    const Padding(padding: EdgeInsets.only(top: 100)),
                  ],
                ),
              ],
            )));
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _getStateText(Room? room) {
    var audioTracksCount = room?.participants.values.where((p) => p.audioTracks.isNotEmpty).length ?? 0;
    var localAudioTracksCount = room?.localParticipant?.audioTracks.length ?? 0;
    if (audioTracksCount == 0) return "Connecting...";
    if (localAudioTracksCount == 0) return "Ringing...";
    if (audioTracksCount > 0) return "Active";

    return "Unknown";
  }
}

class _LocalParticipantWidgetState extends _ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication =>
      widget.participant.videoTracks.where((element) => element.sid == widget.videoTrack?.sid).firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get firstAudioPublication => widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
}

class _RemoteParticipantWidgetState extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication =>
      widget.participant.videoTracks.where((element) => element.sid == widget.videoTrack?.sid).firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get firstAudioPublication => widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.participant.videoTracks.firstOrNull?.track;
}
