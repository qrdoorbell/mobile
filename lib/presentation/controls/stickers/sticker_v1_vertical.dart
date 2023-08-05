import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'sticker_template.dart';

class StickerV1Vertical extends StickerTemplateWidget {
  const StickerV1Vertical({required super.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
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
                clipBehavior: Clip.hardEdge,
                children: [
                  Image.asset('assets/sticker_yellow_vert/qrdoorbell-sticker-5@1x.png', width: 130),
                  const Positioned(
                      left: 15,
                      top: 130,
                      child: Icon(
                        CupertinoIcons.qrcode,
                        color: Colors.black,
                        size: 100,
                      )),
                  const Positioned(
                      width: 135,
                      top: 75,
                      left: 0,
                      child: Text('206',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 38,
                          ))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
