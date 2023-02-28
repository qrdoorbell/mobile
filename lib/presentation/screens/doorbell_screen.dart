import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/presentation/controls/event_card.dart';
import 'package:qrdoorbell_mobile/presentation/controls/sticker_card.dart';

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
        child: Padding(
            padding: EdgeInsets.only(left: 0, top: 10, right: 5),
            child: CustomScrollView(slivers: <Widget>[
              CupertinoSliverNavigationBar(
                padding: EdgeInsetsDirectional.only(start: 5, end: 10),
                backgroundColor: Colors.white,
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.pop(context),
                  color: CupertinoColors.activeBlue,
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Edit",
                    style: TextStyle(color: CupertinoColors.activeBlue),
                  ),
                  onPressed: () {},
                ),
                middle: Text(doorbell.name),
                largeTitle: Padding(padding: EdgeInsets.only(left: 0), child: Text(doorbell.name)),
                previousPageTitle: "Back",
                border: Border.all(width: 0, color: Colors.white),
                alwaysShowMiddle: false,
              ),

              // STICKERS
              SliverList(
                  delegate: SliverChildListDelegate.fixed(<Widget>[
                Row(children: [
                  Padding(padding: EdgeInsets.only(left: 18, top: 10)),
                  Text('Stickers for print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
                  Spacer(),
                  CupertinoButton(child: Text('See all'), onPressed: () => {})
                ]),
                Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: SizedBox(
                        height: 105,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            StickerCard.fromIcon(CupertinoIcons.qrcode, Colors.lightBlueAccent),
                            Padding(padding: EdgeInsets.all(5)),
                            StickerCard.fromIcon(CupertinoIcons.hexagon, Colors.cyan),
                            Padding(padding: EdgeInsets.all(5)),
                            StickerCard.fromIcon(CupertinoIcons.rectangle, Colors.green),
                            Padding(padding: EdgeInsets.all(5)),
                            StickerCard.fromIcon(CupertinoIcons.rectangle_expand_vertical, Colors.yellow),
                            Padding(padding: EdgeInsets.all(5)),
                            StickerCard.fromIcon(CupertinoIcons.doc_append, Colors.orange),
                            Padding(padding: EdgeInsets.all(5)),
                          ],
                        ))),
              ])),

              // EVENTS
              SliverList(
                  delegate: SliverChildListDelegate.fixed(<Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 20, top: 30, right: 5),
                    child: Text('Events', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400))),
              ])),

              SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) => Padding(
                          padding: EdgeInsets.only(left: 18, top: 10, right: 10),
                          child: EventCard(eventName: 'Doorbell event', eventTime: '42m ago')),
                      childCount: 1)),
            ])));
  }
}
