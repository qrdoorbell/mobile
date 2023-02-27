import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final Widget qrcodeSvg = Padding(
    padding: EdgeInsets.only(top: 7, left: 4, right: 4),
    child: SvgPicture.asset(
      'assets/qrcode-blue.svg',
      width: 64,
      height: 64,
      fit: BoxFit.contain,
    ));

class DoorbellListItem extends StatelessWidget {
  final String id;
  final String name;
  final String announce;

  DoorbellListItem({
    required this.id,
    required this.name,
    required this.announce,
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
                child: Padding(
              padding: EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  qrcodeSvg,
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: TextStyle(fontSize: 24)),
                        Padding(padding: EdgeInsets.only(top: 24)),
                        Text(announce, style: TextStyle(color: Colors.grey))
                      ]))
                ],
              ),
            ))));
  }
}
