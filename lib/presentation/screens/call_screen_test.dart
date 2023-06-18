import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';

import '../../data.dart';
import '../../routing.dart';

class TestCallScreen extends StatefulWidget {
  const TestCallScreen({super.key});

  @override
  State<TestCallScreen> createState() => TestCallScreenState();
}

class TestCallScreenState extends State<TestCallScreen> {
  static final logger = Logger('CallScreenState');

  var isMicEnabled = true;
  var isCamEnabled = true;
  var isSpeakerOn = true;
  var isAnswered = false;

  @override
  Widget build(BuildContext context) {
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
                  // TODO: put video renderer here
                  child: Image.asset(
                    'assets/IMG_1694.jpeg',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Column(
                  children: [
                    _topCallControls(context),
                    if (isAnswered) _answeredCallControls(context),
                    if (!isAnswered) ...[
                      const Text(
                        "Home",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 5)),
                      Text(
                        "Doorbell Video",
                        style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 21),
                      ),
                      const Spacer(),
                      _incomingCallControls(context),
                    ],
                    if (isAnswered) ...[
                      const Spacer(),
                      _doorLockControls(context),
                    ],
                  ],
                ),
              ],
            )));
  }

  Widget _topCallControls(BuildContext context) {
    var user = DataStore.of(context).currentUser!;
    return Padding(
      padding: const EdgeInsets.only(top: 48, left: 25, right: 25, bottom: 8),
      child: Row(children: [
        const Spacer(),
        if (isAnswered)
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
            backgroundColor: Colors.white,
            label: Container(
                width: 76,
                alignment: AlignmentDirectional.center,
                child: const Text("00:34:12", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300))),
          ),
        if (!isAnswered)
          Chip(
              backgroundColor: Colors.blueGrey.shade500,
              label: Container(
                  alignment: AlignmentDirectional.center,
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        // child: const Icon(CupertinoIcons.phone_fill_arrow_down_left, color: Colors.white, size: 12),
                        child: Icon(CupertinoIcons.eye_fill, color: Colors.white, size: 16),
                      ),
                      Text("Preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      isMicEnabled = !isMicEnabled;
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
                      isCamEnabled = !isCamEnabled;
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
                onPressed: () => setState(() {
                      isSpeakerOn = !isSpeakerOn;
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
              onPressed: () => setState(() {
                    isAnswered = !isAnswered;
                  })),
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
                RouteStateScope.of(context).go("/doorbells");
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
                    isAnswered = !isAnswered;
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
