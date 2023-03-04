import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../model/doorbell.dart';

typedef DoorbellCallback = void Function(Doorbell doorbell);

final Widget qrcodeSvg = Padding(
    padding: EdgeInsets.only(top: 7, left: 4, right: 4),
    child: SvgPicture.asset(
      'assets/qrcode-blue.svg',
      fit: BoxFit.scaleDown,
    ));

class DoorbellCard extends StatelessWidget {
  final Doorbell doorbell;
  final String announce;
  final DoorbellCallback onTapHandler;

  DoorbellCard({
    required this.doorbell,
    required this.announce,
    required this.onTapHandler,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.grey.shade100,
                  width: 1,
                )),
            shadowColor: Colors.grey.shade100,
            child: InkWell(
                onTap: () => onTapHandler(doorbell),
                child: Padding(
                  padding: EdgeInsets.only(top: 24, left: 22, right: 12, bottom: 32),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 55, child: qrcodeSvg),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(doorbell.name, style: TextStyle(fontSize: 24)),
                            Padding(padding: EdgeInsets.only(top: 9)),
                            Text(announce, style: TextStyle(color: Colors.grey))
                          ]))
                    ],
                  ),
                ))));
  }
}
