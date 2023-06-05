import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../routing.dart';
import '../../../services/callkit_service.dart';
import '../../screens/call_screen.dart';
import '../../screens/empty_screen.dart';

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
  Duration callDuration = Duration.zero;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        callDuration += const Duration(seconds: 1);
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
    var isMicEnabled = room?.localParticipant?.isMicrophoneEnabled() ?? true;
    var isCamEnabled = room?.localParticipant?.isCameraEnabled() ?? false;
    var isSpeakerOn = room?.speakerOn ?? true;

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
                      : EmptyScreen.black().withText('No Video'),
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
                        child: Text(_printDuration(callDuration),
                            style: const TextStyle(
                              color: CupertinoColors.white,
                            ))),
                    const Spacer(),
                    Row(
                      children: [
                        const Spacer(),
                        CupertinoButton(
                            color: CupertinoColors.white.withOpacity(isMicEnabled ? 0.6 : 0.3),
                            borderRadius: const BorderRadius.all(Radius.circular(55)),
                            padding: const EdgeInsets.all(20),
                            child: Icon(
                              isMicEnabled ? CupertinoIcons.mic_solid : CupertinoIcons.mic_slash_fill,
                              color: CupertinoColors.white,
                              size: 36,
                            ),
                            onPressed: () => setState(() {
                                  room?.localParticipant?.setMicrophoneEnabled(!isMicEnabled);
                                })),
                        const Spacer(),
                        CupertinoButton(
                            color: CupertinoColors.white.withOpacity(isCamEnabled ? 0.7 : 0.3),
                            borderRadius: const BorderRadius.all(Radius.circular(55)),
                            padding: const EdgeInsets.all(20),
                            child: SvgPicture.asset(isCamEnabled ? 'assets/video.svg' : 'assets/video.slash.svg', width: 30, height: 30),
                            onPressed: () => setState(() {
                                  room?.localParticipant?.setCameraEnabled(!isCamEnabled);
                                })),
                        const Spacer(),
                        CupertinoButton(
                            color: CupertinoColors.white.withOpacity(isSpeakerOn ? 0.7 : 0.3),
                            borderRadius: const BorderRadius.all(Radius.circular(55)),
                            padding: const EdgeInsets.all(20),
                            child: Icon(
                              isSpeakerOn ? CupertinoIcons.speaker_3_fill : CupertinoIcons.speaker_3,
                              color: CupertinoColors.white,
                              size: 36,
                            ),
                            onPressed: () => setState(() {
                                  room?.setSpeakerOn(!isSpeakerOn);
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
                          await router.go('/doorbells/${widget.doorbellId}');
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
    if (localAudioTracksCount == 0) return "Preview";
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
