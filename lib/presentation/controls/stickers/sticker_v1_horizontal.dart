import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'sticker_template.dart';

class StickerV1Horizontal extends StickerTemplateWidget {
  const StickerV1Horizontal({required super.controller});

  @override
  Widget build(BuildContext context) {
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
                  const Positioned(
                    width: 120,
                    top: 40,
                    left: 0,
                    child: Text('206',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
