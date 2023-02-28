import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/doorbell.dart';

class DoorbellScreen extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;
  final Doorbell doorbell;

  DoorbellScreen({
    super.key,
    required this.doorbell,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          backgroundColor: Colors.white,
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => Navigator.pop(context),
            color: CupertinoColors.activeBlue,
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: SizedBox(
                width: 70,
                child: Row(children: [
                  Icon(CupertinoIcons.gear),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Text(
                    "Edit",
                    style: TextStyle(color: CupertinoColors.activeBlue),
                  )
                ])),
            onPressed: () {},
          ),
          middle: Text(doorbell.name),
          largeTitle: Text(doorbell.name),
          previousPageTitle: "Back",
          border: Border.all(width: 0, color: Colors.white),
        ),
      ],
    ));
  }
}
