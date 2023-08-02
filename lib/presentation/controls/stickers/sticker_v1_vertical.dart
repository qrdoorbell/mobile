import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StickerV1Vertical extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 130,
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 20, spreadRadius: 0)],
                    color: Colors.white,
                    border: Border.all(color: Colors.yellow.shade600, style: BorderStyle.solid, width: 8),
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 2)),
                  child: Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, mainAxisSize: MainAxisSize.max, children: [
                    SizedBox(height: 100, child: Center(child: Text("69", style: const TextStyle(fontSize: 42)))),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        width: 110,
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 2)),
                        child: const Icon(
                          CupertinoIcons.qrcode,
                          color: Colors.black,
                          size: 100,
                        ),
                      ),
                    ),
                    Container(
                      width: 130,
                      height: 101,
                      decoration:
                          BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 2)),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.bell_fill,
                          color: Colors.yellow.shade600,
                          size: 80,
                        ),
                      ),
                    ),
                  ])),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
