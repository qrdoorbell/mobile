import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:qrdoorbell_mobile/routing.dart';

class ParticipantTrack {
  ParticipantTrack({required this.participant, required this.videoTrack});
  VideoTrack? videoTrack;
  Participant participant;
}

abstract class ParticipantWidget extends StatefulWidget {
  abstract final Participant participant;
  abstract final VideoTrack? videoTrack;
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

  const LocalParticipantWidget(
    this.participant,
    this.videoTrack, {
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

  const RemoteParticipantWidget(
    this.participant,
    this.videoTrack, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget> extends State<T> {
  bool _visible = true;
  VideoTrack? get activeVideoTrack;
  TrackPublication? get videoPublication;
  TrackPublication? get firstAudioPublication;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
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
  Widget build(BuildContext context) => Scaffold(
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
                    : const Text('NO VIDEO'),
              ),
              Column(
                children: [
                  const Padding(padding: EdgeInsets.only(top: 140)),
                  Text(
                    activeVideoTrack != null ? 'Active' : 'Connecting...',
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                  const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('00:02',
                          style: TextStyle(
                            color: CupertinoColors.white,
                          ))),
                  const Spacer(),
                  Row(
                    children: [
                      const Spacer(),
                      CupertinoButton(
                          color: CupertinoColors.white.withOpacity(0.3),
                          borderRadius: const BorderRadius.all(Radius.circular(55)),
                          padding: const EdgeInsets.all(25),
                          child: const Icon(
                            CupertinoIcons.mic_solid,
                            color: CupertinoColors.white,
                            size: 40,
                          ),
                          onPressed: () => {}),
                      const Spacer(),
                      CupertinoButton(
                          color: CupertinoColors.white.withOpacity(0.3),
                          borderRadius: const BorderRadius.all(Radius.circular(55)),
                          padding: const EdgeInsets.all(25),
                          child: const Icon(
                            CupertinoIcons.video_camera_solid,
                            color: CupertinoColors.white,
                            size: 40,
                          ),
                          onPressed: () => {}),
                      const Spacer(),
                      CupertinoButton(
                          color: CupertinoColors.white.withOpacity(0.6),
                          borderRadius: const BorderRadius.all(Radius.circular(55)),
                          padding: const EdgeInsets.all(25),
                          child: const Icon(
                            CupertinoIcons.speaker_3_fill,
                            color: CupertinoColors.white,
                            size: 40,
                          ),
                          onPressed: () => {}),
                      const Spacer(),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 80)),
                  CupertinoButton(
                      color: CupertinoColors.destructiveRed,
                      borderRadius: const BorderRadius.all(Radius.circular(55)),
                      padding: const EdgeInsets.all(25),
                      child: const Icon(
                        CupertinoIcons.phone_down_fill,
                        color: CupertinoColors.white,
                        size: 40,
                      ),
                      onPressed: () async {
                        await widget.participant.unpublishAllTracks();
                        await widget.participant.dispose();
                        await RouteStateScope.of(context).go('/doorbells');
                      }),
                  const Padding(padding: EdgeInsets.only(top: 100)),
                ],
              ),
            ],
          ),
        ),
      );
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
