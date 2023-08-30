import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sticker_v11_controller.dart';
import 'sticker_v11_horizontal_preview.dart';
import 'sticker_v11_vertical_preview.dart';

abstract class StickerV11Preview extends StatelessWidget {
  final StickerV11Controller controller;

  MaterialColor get color => controller.sticker.data.accentColor ?? Colors.yellow;

  Widget get textWidget => GestureDetector(
        onTap: () => controller.isEditingText = true,
        child: FittedBox(
            alignment: Alignment.center,
            fit: BoxFit.contain,
            child: Text(controller.sticker.data.apt,
                overflow: TextOverflow.visible, textAlign: TextAlign.center, style: const TextStyle(fontSize: 42))),
      );

  Widget get iconWidget;

  @protected
  dynamic buildSticker();

  const StickerV11Preview({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StickerV11Controller>.value(
        value: controller,
        builder: (context, c) => SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Align(
                heightFactor: 0.6,
                alignment: Alignment.center,
                child: Container(
                    clipBehavior: Clip.none,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: CupertinoColors.systemGrey2, blurRadius: 15)]),
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: color.shade600, width: 6),
                            borderRadius: BorderRadius.circular(14),
                            color: color.shade600),
                        padding: const EdgeInsets.all(3),
                        child: Stack(children: buildSticker()))),
              ),
            ));
  }

  factory StickerV11Preview.create({required StickerV11Controller controller}) => controller.sticker.data.vertical != false
      ? StickerV11VerticalPreview(controller: controller)
      : StickerV11HorizontalPreview(controller: controller);
}
