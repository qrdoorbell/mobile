import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'sticker_v11_controller.dart';
import 'sticker_v11_preview.dart';

class StickerV11HorizontalPreview extends StickerV11Preview {
  @override
  Widget get iconWidget => Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.black),
      width: 100,
      height: 90,
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
        Positioned(left: 224, top: 5, child: iconWidget),
        Positioned(left: 5, top: 3, child: Image.asset('assets/sticker_v1.1/text_scan_doorbell.png', width: 105)),
        Positioned(
            width: 90,
            height: 45,
            top: 42,
            left: 15,
            child: Focus(
              focusNode: controller.aptTextFocusNode,
              child: textWidget,
            )),
      ];

  StickerV11HorizontalPreview({required StickerV11Controller controller}) : super(controller: controller) {
    assert(controller.sticker.data.vertical != true);
  }
}
