import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

extension VideoScreenExtensions on BuildContext {
  Future<bool?> showPublishDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Publish'),
          content: const Text('Would you like to publish your Camera & Mic ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('YES'),
            ),
          ],
        ),
      );

  Future<bool?> showUnPublishDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('UnPublish'),
          content: const Text('Would you like to un-publish your Camera & Mic ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('YES'),
            ),
          ],
        ),
      );

  Future<void> showErrorDialog(dynamic exception) => showDialog<void>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(exception.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            )
          ],
        ),
      );

  Future<bool?> showDisconnectDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Disconnect'),
          content: const Text('Are you sure to disconnect?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Disconnect'),
            ),
          ],
        ),
      );

  Future<bool?> showReconnectDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Reconnect'),
          content: const Text('This will force a reconnection'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reconnect'),
            ),
          ],
        ),
      );

  Future<void> showReconnectSuccessDialog() => showDialog<void>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Reconnect'),
          content: const Text('Reconnection was successful.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );

  Future<bool?> showSendDataDialog() => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Send data'),
          content: const Text('This will send a sample data to all participants in the room'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Send'),
            ),
          ],
        ),
      );

  Future<bool?> showDataReceivedDialog(String data) => showDialog<bool>(
        context: this,
        builder: (ctx) => AlertDialog(
          title: const Text('Received data'),
          content: Text(data),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('OK'),
            ),
          ],
        ),
      );
}

enum SimulateScenarioResult {
  signalReconnect,
  nodeFailure,
  migration,
  serverLeave,
  switchCandidate,
  clear,
}

class CallScreen extends StatefulWidget {
  final String accessToken;

  const CallScreen({super.key, required this.accessToken});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final Room room;
  late final EventsListener<RoomEvent> listener;

  @override
  void initState() {
    super.initState();
    room = Room();
    listener = room.createListener();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: room.connect('http://10.9.9.126:7880', widget.accessToken,
            roomOptions: const RoomOptions(
              adaptiveStream: true,
              dynacast: true,
              defaultVideoPublishOptions: VideoPublishOptions(
                simulcast: false,
              ),
              defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(),
            ),
            fastConnectOptions: FastConnectOptions(
              microphone: const TrackOption(enabled: true),
              camera: const TrackOption(enabled: true),
            )),
        builder: (context, snapshot) => VideoCall(room, listener));
  }
}

class VideoCall extends StatefulWidget {
  //
  final Room room;
  final EventsListener<RoomEvent> listener;

  const VideoCall(
    this.room,
    this.listener, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  //
  List<ParticipantTrack> participantTracks = [];
  EventsListener<RoomEvent> get _listener => widget.listener;
  bool get fastConnection => widget.room.engine.fastConnectOptions != null;
  @override
  void initState() {
    super.initState();
    widget.room.addListener(_onRoomDidUpdate);
    _setUpListeners();
    _sortParticipants();
    WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
      if (!fastConnection) {
        _askPublish();
      }
    });
  }

  @override
  void dispose() {
    // always dispose listener
    (() async {
      widget.room.removeListener(_onRoomDidUpdate);
      await _listener.dispose();
      await widget.room.dispose();
    })();
    super.dispose();
  }

  void _setUpListeners() => _listener
    ..on<RoomDisconnectedEvent>((event) async {
      if (event.reason != null) {
        print('Room disconnected: reason => ${event.reason}');
      }
      WidgetsBindingCompatible.instance?.addPostFrameCallback((timeStamp) => Navigator.pop(context));
    })
    ..on<LocalTrackPublishedEvent>((_) => _sortParticipants())
    ..on<LocalTrackUnpublishedEvent>((_) => _sortParticipants())
    ..on<DataReceivedEvent>((event) {
      String decoded = 'Failed to decode';
      try {
        decoded = utf8.decode(event.data);
      } catch (_) {
        print('Failed to decode: $_');
      }
      context.showDataReceivedDialog(decoded);
    });

  void _askPublish() async {
    final result = await context.showPublishDialog();
    if (result != true) return;

    // video will fail when running in ios simulator
    try {
      await widget.room.localParticipant?.setCameraEnabled(true);
    } catch (error) {
      print('could not publish video: $error');
      // await context.showErrorDialog(error);
    }

    try {
      await widget.room.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      print('could not publish audio: $error');
      // await context.showErrorDialog(error);
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _sortParticipants() {
    List<ParticipantTrack> userMediaTracks = [];
    for (var participant in widget.room.participants.values)
      for (var t in participant.videoTracks)
        userMediaTracks.add(ParticipantTrack(
          participant: participant,
          videoTrack: t.track,
        ));

    final localParticipantTracks = widget.room.localParticipant?.videoTracks;
    if (localParticipantTracks != null)
      for (var t in localParticipantTracks)
        userMediaTracks.add(ParticipantTrack(
          participant: widget.room.localParticipant!,
          videoTrack: t.track,
        ));

    setState(() {
      participantTracks = [...userMediaTracks];
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Expanded(child: participantTracks.isNotEmpty ? ParticipantWidget.widgetFor(participantTracks.first) : Container()),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: math.max(0, participantTracks.length - 1),
                itemBuilder: (BuildContext context, int index) => SizedBox(
                  width: 100,
                  height: 100,
                  child: ParticipantWidget.widgetFor(participantTracks[index + 1]),
                ),
              ),
            ),
            // if (widget.room.localParticipant != null)
            //   SafeArea(
            //     top: false,
            //     child: ControlsWidget(widget.room, widget.room.localParticipant!),
            //   ),
          ],
        ),
      );
}

class ParticipantTrack {
  ParticipantTrack({required this.participant, required this.videoTrack});
  VideoTrack? videoTrack;
  Participant participant;
}

class ParticipantInfoWidget extends StatelessWidget {
  //
  final String? title;
  final bool audioAvailable;
  final ConnectionQuality connectionQuality;

  const ParticipantInfoWidget({
    this.title,
    this.audioAvailable = true,
    this.connectionQuality = ConnectionQuality.unknown,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null)
              Flexible(
                child: Text(
                  title!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 5),
            //   child: Icon(
            //     audioAvailable ? CupertinoIcons.mic : CupertinoIcons.mic_off,
            //     color: audioAvailable ? Colors.white : Colors.red,
            //     size: 16,
            //   ),
            // ),
            // if (connectionQuality != ConnectionQuality.unknown)
            //   Padding(
            //     padding: const EdgeInsets.only(left: 5),
            //     child: Icon(
            //       connectionQuality == ConnectionQuality.poor ? CupertinoIcons.wifi_slash : CupertinoIcons.wifi,
            //       color: {
            //         ConnectionQuality.excellent: Colors.green,
            //         ConnectionQuality.good: Colors.orange,
            //         ConnectionQuality.poor: Colors.red,
            //       }[connectionQuality],
            //       size: 16,
            //     ),
            //   ),
          ],
        ),
      );
}

abstract class ParticipantWidget extends StatefulWidget {
  static ParticipantWidget widgetFor(ParticipantTrack participantTrack) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(participantTrack.participant as LocalParticipant, participantTrack.videoTrack);
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(participantTrack.participant as RemoteParticipant, participantTrack.videoTrack);
    }
    throw UnimplementedError('Unknown participant type');
  }

  // Must be implemented by child class
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

  // Notify Flutter that UI re-build is required, but we don't set anything here
  // since the updated values are computed properties.
  void _onParticipantChanged() => setState(() {});

  @override
  Widget build(BuildContext ctx) => Container(
        foregroundDecoration: BoxDecoration(
          border: widget.participant.isSpeaking
              ? Border.all(
                  width: 5,
                  color: Colors.blue,
                )
              : null,
        ),
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
        ),
        child: Stack(
          children: [
            // Video
            InkWell(
              onTap: () => setState(() => _visible = !_visible),
              child: activeVideoTrack != null && !activeVideoTrack!.muted
                  ? VideoTrackRenderer(
                      activeVideoTrack!,
                      fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    )
                  : const Text('NO VIDEO'),
            ),

            // Bottom bar
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.stretch,
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       ParticipantInfoWidget(
            //         title: widget.participant.name.isNotEmpty
            //             ? '${widget.participant.name} (${widget.participant.identity})'
            //             : widget.participant.identity,
            //         audioAvailable: firstAudioPublication?.muted == false && firstAudioPublication?.subscribed == true,
            //         connectionQuality: widget.participant.connectionQuality,
            //       ),
            //     ],
            //   ),
            // ),
          ],
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
  // VideoTrack? get activeVideoTrack => widget.videoTrack;
  VideoTrack? get activeVideoTrack => widget.participant.videoTracks.firstOrNull?.track;
}

class RemoteTrackPublicationMenuWidget extends StatelessWidget {
  final IconData icon;
  final RemoteTrackPublication pub;
  const RemoteTrackPublicationMenuWidget({
    required this.pub,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withOpacity(0.3),
        child: PopupMenuButton<Function>(
          tooltip: 'Subscribe menu',
          icon: Icon(icon,
              color: {
                TrackSubscriptionState.notAllowed: Colors.red,
                TrackSubscriptionState.unsubscribed: Colors.grey,
                TrackSubscriptionState.subscribed: Colors.green,
              }[pub.subscriptionState]),
          onSelected: (value) => value(),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Function>>[
            // Subscribe/Unsubscribe
            if (pub.subscribed == false)
              PopupMenuItem(
                child: const Text('Subscribe'),
                value: () => pub.subscribe(),
              )
            else if (pub.subscribed == true)
              PopupMenuItem(
                child: const Text('Unsubscribe'),
                value: () => pub.unsubscribe(),
              ),
          ],
        ),
      );
}
