import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../sticker_edit_controller.dart';
import 'sticker_v1_data.dart';

class StickerV1Preview extends StatefulWidget {
  final StickerEditController<StickerV1Data> controller;
  final Widget templateImageWidget;
  final Widget qrcodeWidget;
  final Widget textWidget;

  factory StickerV1Preview.create({required StickerEditController<StickerV1Data> controller}) => controller.sticker.data.vertical != false
      ? StickerV1Preview._vertical(controller: controller)
      : StickerV1Preview._horizontal(controller: controller);

  factory StickerV1Preview._horizontal({required StickerEditController<StickerV1Data> controller}) {
    return StickerV1Preview._(
        controller: controller,
        templateImageWidget: Image.asset('assets/sticker_yellow_hor/qrdoorbell-sticker-5_horizontal@1x.png', width: 330),
        qrcodeWidget: const Positioned(top: 8, left: 115, child: Icon(CupertinoIcons.qrcode, color: Colors.black, size: 100)),
        textWidget: Positioned(
            width: 90,
            height: 45,
            top: 42,
            left: 15,
            child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.contain,
                child: Text(controller.sticker.data.apt,
                    overflow: TextOverflow.visible, textAlign: TextAlign.center, style: const TextStyle(fontSize: 42)))));
  }

  factory StickerV1Preview._vertical({required StickerEditController<StickerV1Data> controller}) {
    return StickerV1Preview._(
        controller: controller,
        templateImageWidget: Image.asset('assets/sticker_yellow_vert/qrdoorbell-sticker-5@1x.png', width: 130),
        qrcodeWidget: const Positioned(left: 15, top: 130, child: Icon(CupertinoIcons.qrcode, color: Colors.black, size: 100)),
        textWidget: Positioned(
            width: 100,
            height: 45,
            top: 75,
            left: 15,
            child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.contain,
                child: Text(controller.sticker.data.apt,
                    overflow: TextOverflow.visible, textAlign: TextAlign.center, style: const TextStyle(fontSize: 42)))));
  }

  const StickerV1Preview._(
      {required this.controller, required this.templateImageWidget, required this.qrcodeWidget, required this.textWidget});

  @override
  State<StickerV1Preview> createState() => _StickerV1PreviewState();
}

class _StickerV1PreviewState extends State<StickerV1Preview> {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Center(
          child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: CupertinoColors.systemGrey2, blurRadius: 15)]),
              child: Stack(children: [widget.templateImageWidget, widget.qrcodeWidget, widget.textWidget])))
    ]);
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
