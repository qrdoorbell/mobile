import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../sticker_edit_controller.dart';
import 'sticker_data.dart';

class StickerV11Preview extends StatefulWidget {
  final StickerEditController<StickerV1Data> controller;
  final dynamic children;

  MaterialColor get color => controller.sticker.data.accentColor ?? Colors.yellow;

  factory StickerV11Preview.create({required StickerEditController<StickerV1Data> controller}) => controller.sticker.data.vertical != false
      ? StickerV11Preview._vertical(controller: controller)
      : StickerV11Preview._horizontal(controller: controller);

  factory StickerV11Preview._vertical({required StickerEditController<StickerV1Data> controller}) {
    return StickerV11Preview._(controller: controller, children: [
      Image.asset('assets/sticker_v1.1/template_1.1_vertical.png', width: 130), // Real image size: 347x1038
      const Positioned(
          left: 0,
          top: 129,
          width: 130,
          height: 130,
          child: FittedBox(
              clipBehavior: Clip.none,
              fit: BoxFit.none,
              alignment: Alignment.center,
              child: Icon(CupertinoIcons.qrcode, color: Colors.black, size: 140))),
      Positioned(
          left: 5,
          top: 260,
          child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.black),
              width: 120,
              height: 105,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    child:
                        Icon(CupertinoIcons.bell_fill, color: (controller.sticker.data.accentColor ?? Colors.yellow).shade500, size: 140)),
              ))),
      Positioned(left: 5, top: 35, child: Image.asset('assets/sticker_v1.1/text_scan_doorbell.png', width: 120)),
      Positioned(
          width: 100,
          height: 40,
          top: 85,
          left: 15,
          child: FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.contain,
              child: Text(controller.sticker.data.apt,
                  overflow: TextOverflow.visible, textAlign: TextAlign.center, style: const TextStyle(fontSize: 42))))
    ]);
  }

  factory StickerV11Preview._horizontal({required StickerEditController<StickerV1Data> controller}) {
    return StickerV11Preview._(controller: controller, children: [
      Image.asset('assets/sticker_v1.1/template_1.1_horizontal.png', width: 330),
      const Positioned(
          left: 107,
          top: -6,
          width: 120,
          height: 120,
          child: FittedBox(
              clipBehavior: Clip.none,
              fit: BoxFit.none,
              alignment: Alignment.center,
              child: Icon(CupertinoIcons.qrcode, color: Colors.black, size: 120))),
      Positioned(
          left: 224,
          top: 5,
          child: Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.black),
              width: 100,
              height: 90,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    child: Text(
                      'A',
                      style: TextStyle(fontFamily: 'SF Pro', color: Colors.white),
                    )),
                // Icon(CupertinoIcons.bell_fill, color: (controller.sticker.data.accentColor ?? Colors.yellow).shade500, size: 110)),
              ))),
      Positioned(left: 5, top: 3, child: Image.asset('assets/sticker_v1.1/text_scan_doorbell.png', width: 105)),
      Positioned(
          width: 90,
          height: 45,
          top: 42,
          left: 15,
          child: FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.contain,
              child: Text(controller.sticker.data.apt,
                  overflow: TextOverflow.visible, textAlign: TextAlign.center, style: const TextStyle(fontSize: 42))))
    ]);
  }

  const StickerV11Preview._({
    required this.controller,
    this.children = const <Widget>[],
  });

  @override
  State<StickerV11Preview> createState() => _StickerV1PreviewState();
}

class _StickerV1PreviewState extends State<StickerV11Preview> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Center(
            child: Container(
                clipBehavior: Clip.none,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: CupertinoColors.systemGrey2, blurRadius: 15)]),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: widget.color.shade600, width: 6),
                        borderRadius: BorderRadius.circular(14),
                        color: widget.color.shade600),
                    padding: const EdgeInsets.all(3),
                    child: Stack(children: widget.children))))
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  void _controllerListener() {
    setState(() {});
  }
}
