import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'sticker_template.dart';

class StickerV1Horizontal extends StickerTemplateWidget {
  const StickerV1Horizontal({required super.controller});

  @override
  Widget build(BuildContext context) {
    var text = controller.getValue<String>('apt') ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 330,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: CupertinoColors.systemGrey2,
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Image.asset('assets/sticker_yellow_hor/qrdoorbell-sticker-5_horizontal@1x.png', width: 330),
                  const Positioned(
                      top: 8,
                      left: 115,
                      child: Icon(
                        CupertinoIcons.qrcode,
                        color: Colors.black,
                        size: 100,
                      )),
                  Positioned(
                    width: 120,
                    top: 40,
                    left: 0,
                    child: Text(text,
                        overflow: TextOverflow.fade,
                        textScaleFactor: text.length > 3
                            ? 0.8
                            : text.length < 3
                                ? 1.2
                                : 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 38,
                        )),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
