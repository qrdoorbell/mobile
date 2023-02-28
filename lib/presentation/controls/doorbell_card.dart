import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../model/doorbell.dart';
import '../screens/doorbell_screen.dart';

final Widget qrcodeSvg = Padding(
    padding: EdgeInsets.only(top: 7, left: 4, right: 4),
    child: SvgPicture.asset(
      'assets/qrcode-blue.svg',
      width: 64,
      height: 64,
      fit: BoxFit.contain,
    ));

class DoorbellCard extends StatelessWidget {
  final Doorbell doorbell;
  final String announce;

  DoorbellCard({
    required this.doorbell,
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
                onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                        settings: RouteSettings(name: "/doorbells/${doorbell.id}"),
                        pageBuilder: (context, animation, secondaryAnimation) => DoorbellScreen(doorbell: doorbell))),
                child: Padding(
                  padding: EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 48),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      qrcodeSvg,
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 18),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(doorbell.name, style: TextStyle(fontSize: 24)),
                            Padding(padding: EdgeInsets.only(top: 24)),
                            Text(announce, style: TextStyle(color: Colors.grey))
                          ]))
                    ],
                  ),
                ))));
  }
}