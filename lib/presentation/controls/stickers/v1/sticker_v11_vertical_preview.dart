import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'sticker_v11_controller.dart';
import 'sticker_v11_preview.dart';

class StickerV11VerticalPreview extends StickerV11Preview {
  @override
  Widget get iconWidget => Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.black),
      width: 120,
      height: 105,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: GestureDetector(
              onTap: () => controller.isIconPickerVisible = true,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    child: Icon(controller.sticker.data.icon ?? CupertinoIcons.bell_fill, size: 180, color: color.shade600),
                  )))));

  @override
  buildSticker() => [
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
        Positioned(left: 5, top: 260, child: iconWidget),
        Positioned(left: 5, top: 35, child: Image.asset('assets/sticker_v1.1/text_scan_doorbell.png', width: 120)),
        Positioned(
            width: 100,
            height: 40,
            top: 85,
            left: 15,
            child: Focus(
              focusNode: controller.aptTextFocusNode,
              child: textWidget,
            )),
      ];

  StickerV11VerticalPreview({required StickerV11Controller controller}) : super(controller: controller) {
    assert(controller.sticker.data.vertical != false);
  }
}
