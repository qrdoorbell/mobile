import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../model/sticker.dart';

class StickerV1Icon extends StatelessWidget {
  final StickerInfo sticker;
  final MaterialColor color;
  final Widget? topChild;

  const StickerV1Icon({
    super.key,
    required this.sticker,
    this.color = Colors.yellow,
    this.topChild,
  });

  Widget? _getTextIcon() {
    var text = sticker.getOrDefault('apt', '').trim();
    if (text.isEmpty) return null;

    return Text(
      text,
      overflow: TextOverflow.visible,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(color: color.shade700, fontWeight: FontWeight.normal, letterSpacing: -2, fontSize: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    var icon = topChild ?? _getTextIcon() ?? Icon(CupertinoIcons.signature, color: color.shade700, size: 32);

    // HORIZONTAL
    if (sticker.getOrDefault('vertical', true) == false) {
      return Container(
        decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 34, height: 32, child: Center(child: FittedBox(fit: BoxFit.fitWidth, child: icon))),
            Icon(CupertinoIcons.qrcode, color: color.shade700, size: 32),
          ],
        ),
      );
    }

    // VERTICAL
    return Container(
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Spacer(),
          SizedBox(width: 28, height: 32, child: Center(child: FittedBox(fit: BoxFit.fitWidth, child: icon))),
          const Spacer(),
          Icon(CupertinoIcons.qrcode, color: color.shade700, size: 32),
        ],
      ),
    );
  }
}
