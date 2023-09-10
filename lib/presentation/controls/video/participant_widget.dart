import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app_options.dart';
import '../../../data.dart';
import '../../../tools.dart';
import '../../screens/empty_screen.dart';

class ParticipantTrack {
  ParticipantTrack({required this.participant, required this.videoTrack});
  VideoTrack? videoTrack;
  Participant participant;
}

abstract class ParticipantWidget extends StatefulWidget {
  abstract final Participant participant;
  abstract final String doorbellId;
  final Room room;
  final VideoQuality quality;
  final BuildContextCallback endCall;
  final bool isAnswered;

  const ParticipantWidget(
    this.room,
    this.endCall, {
    this.isAnswered = false,
    this.quality = VideoQuality.MEDIUM,
    Key? key,
  }) : super(key: key);
}

abstract class ParticipantWidgetState<T extends ParticipantWidget> extends State<T> {
  Timer? timer;
  bool _visible = true;
  bool _isAnswered = false;
  Duration _callDuration = Duration.zero;

  TrackPublication? get videoPublication;
  TrackPublication? get firstAudioPublication;

  bool get isMicEnabled => widget.room.localParticipant?.isMicrophoneEnabled() ?? false;
  bool get isCamEnabled => widget.room.localParticipant?.isCameraEnabled() ?? false;
  bool get isSpeakerOn => widget.room.speakerOn ?? true;

  @override
  void initState() {
    _isAnswered = widget.isAnswered;
    _callDuration = Duration(milliseconds: DateTime.now().millisecond - widget.participant.joinedAt.millisecond);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _callDuration += const Duration(seconds: 1);
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
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: CupertinoColors.darkBackgroundGray,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.topCenter,
          children: [
            InkWell(
              onTap: () => setState(() => _visible = !_visible),
              child: videoPublication != null && videoPublication!.track != null && videoPublication!.track is VideoTrack
                  ? VideoTrackRenderer(
                      videoPublication!.track as VideoTrack,
                      fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : EmptyScreen.black().withText('No Video'),
            ),
            Column(
              children: [
                _topCallControls(context),
                if (_isAnswered)
                  _answeredCallControls(context)
                else ...[
                  Text(
                    DataStore.of(context).getDoorbellById(widget.doorbellId)?.name ?? "Doorbell",
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 5)),
                  Text(
                    "Doorbell Video",
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 21),
                  ),
                  const Spacer(),
                  _incomingCallControls(context),
                ],
                if (_isAnswered && AppSettings.homekitEnabled) ...[
                  const Spacer(),
                  _doorLockControls(context),
                ],
              ],
            ),
          ],
        ));
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _getStateText(Room room) {
    var audioTracksCount = room.participants.values.where((p) => p.audioTracks.isNotEmpty).length ?? 0;
    var localAudioTracksCount = room.localParticipant?.audioTracks.length ?? 0;
    if (audioTracksCount == 0) return "Connecting...";
    if (localAudioTracksCount == 0) return "Preview";
    if (audioTracksCount > 0) return "Active";

    return "Unknown";
  }

  Widget _topCallControls(BuildContext context) {
    var user = DataStore.of(context).currentUser!;
    return Padding(
      padding: const EdgeInsets.only(top: 48, left: 25, right: 25, bottom: 8),
      child: Row(children: [
        const Spacer(),
        if (_isAnswered)
          Chip(
            avatar: CircleAvatar(
                backgroundColor: user.getAvatarColor(),
                minRadius: 20,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    user.getShortName(),
                    textScaleFactor: 1,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )),
            backgroundColor: Colors.grey.shade600,
            label: Container(
                width: 76,
                alignment: AlignmentDirectional.center,
                child: Text(_printDuration(_callDuration), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300))),
          )
        else
          Chip(
              backgroundColor: Colors.grey.shade600,
              label: Container(
                  alignment: AlignmentDirectional.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(CupertinoIcons.eye_fill, color: Colors.white, size: 16),
                      ),
                      Text(_getStateText(widget.room), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ))),
        const Spacer(),
      ]),
    );
  }

  Widget _answeredCallControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CupertinoButton(
                color: isMicEnabled ? Colors.white : const Color(0xee606060),
                borderRadius: const BorderRadius.all(Radius.circular(55)),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Icon(
                    isMicEnabled ? CupertinoIcons.mic_solid : CupertinoIcons.mic_slash_fill,
                    color: isMicEnabled ? Colors.black : const Color(0xFFffffff),
                    opticalSize: 36,
                    size: 30,
                  ),
                ),
                onPressed: () => setState(() {
                      widget.room.localParticipant?.setMicrophoneEnabled(!isMicEnabled);
                    })),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CupertinoButton(
                color: isCamEnabled ? Colors.white : const Color(0xee606060),
                borderRadius: const BorderRadius.all(Radius.circular(55)),
                padding: const EdgeInsets.all(10),
                minSize: 58,
                onPressed: () => setState(() {
                      widget.room.localParticipant?.setCameraEnabled(!isCamEnabled);
                    }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: isCamEnabled
                      ? SvgPicture.asset('assets/video.fill.svg', width: 18, height: 18)
                      : SvgPicture.asset('assets/video.slash.fill.svg', width: 24, height: 24),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CupertinoButton(
                color: isSpeakerOn ? Colors.white : const Color(0xee606060),
                borderRadius: const BorderRadius.all(Radius.circular(55)),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Icon(
                    isSpeakerOn ? CupertinoIcons.speaker_2_fill : CupertinoIcons.speaker_slash_fill,
                    color: isSpeakerOn ? Colors.black : const Color(0xFFffffff),
                    opticalSize: 36,
                    size: 32,
                  ),
                ),
                onPressed: () => setState(() async {
                      await widget.room.setSpeakerOn(!isSpeakerOn);
                    })),
          ),
          const Spacer(),
          CupertinoButton(
              color: CupertinoColors.destructiveRed,
              borderRadius: const BorderRadius.all(Radius.circular(55)),
              padding: const EdgeInsets.all(10),
              child: const Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(
                  CupertinoIcons.clear,
                  color: CupertinoColors.white,
                  opticalSize: 36,
                  size: 32,
                ),
              ),
              onPressed: () async {
                await widget.endCall(context);
                if (mounted) setState(() {});
              }),
        ],
      ),
    );
  }

  Widget _incomingCallControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 80),
      child: Row(
        children: [
          const Spacer(),
          CupertinoButton(
              color: CupertinoColors.destructiveRed,
              borderRadius: const BorderRadius.all(Radius.circular(55)),
              padding: const EdgeInsets.all(10),
              minSize: 85,
              child: const Icon(
                CupertinoIcons.phone_down_fill,
                color: CupertinoColors.white,
                size: 42,
              ),
              onPressed: () async {
                await widget.endCall(context);
                setState(() {});
              }),
          const Spacer(),
          const Spacer(),
          const Spacer(),
          CupertinoButton(
              color: CupertinoColors.activeGreen,
              borderRadius: const BorderRadius.all(Radius.circular(55)),
              padding: const EdgeInsets.all(10),
              minSize: 85,
              child: const Icon(
                CupertinoIcons.phone_solid,
                color: CupertinoColors.white,
                size: 45,
              ),
              onPressed: () => setState(() {
                    _isAnswered = true;
                    widget.room.localParticipant?.setMicrophoneEnabled(true);
                    widget.room.localParticipant?.setCameraEnabled(true);
                  })),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _doorLockControls(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(
                decoration: const ShapeDecoration(
                    shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3, strokeAlign: 2, style: BorderStyle.solid))),
                child: CupertinoButton(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(55)),
                    padding: const EdgeInsets.all(10),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        CupertinoIcons.lock_open_fill,
                        color: Colors.black,
                        opticalSize: 36,
                        size: 30,
                      ),
                    ),
                    onPressed: () => setState(() {})),
              ),
              const Spacer(),
            ])));
  }
}
