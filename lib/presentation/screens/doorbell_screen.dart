import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/data.dart';
import 'package:qrdoorbell_mobile/presentation/controls/event_list.dart';
import 'package:qrdoorbell_mobile/presentation/controls/sticker_card.dart';

import '../../routing.dart';

class DoorbellScreen extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;
  final String doorbellId;

  DoorbellScreen({
    super.key,
    required this.doorbellId,
  });

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore.of(context);
    final doorbell = dataStore.getDoorbellById(doorbellId)!;
    FloatingActionButton? floatButton;

    if (dataStore.doorbellEvents.any((x) => x.doorbellId == doorbellId)) {
      floatButton = FloatingActionButton(onPressed: _onShareDoorbell, child: const Icon(CupertinoIcons.share));
    }

    return CupertinoPageScaffold(
        child: Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: floatButton,
      backgroundColor: Colors.white,
      body: Padding(
          padding: const EdgeInsets.only(left: 0, top: 10, right: 5),
          child: CustomScrollView(slivers: <Widget>[
            CupertinoSliverNavigationBar(
              padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
              backgroundColor: Colors.white,
              leading: CupertinoNavigationBarBackButton(
                onPressed: () => Navigator.pop(context),
                color: CupertinoColors.activeBlue,
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text(
                  "Edit",
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
                onPressed: () => RouteStateScope.of(context).go('/doorbells/$doorbellId/edit'),
              ),
              middle: Text(doorbell.name),
              largeTitle: Padding(padding: const EdgeInsets.only(left: 0), child: Text(doorbell.name)),
              previousPageTitle: "Back",
              border: Border.all(width: 0, color: Colors.white),
              alwaysShowMiddle: false,
            ),

            // STICKERS
            SliverList(
                delegate: SliverChildListDelegate.fixed(<Widget>[
              Row(children: [
                const Padding(padding: EdgeInsets.only(left: 18, top: 10)),
                const Text('Stickers for print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
                const Spacer(),
                CupertinoButton(child: const Text('See all'), onPressed: () => {})
              ]),
              Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: SizedBox(
                      height: 105,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          StickerCard.fromIcon(CupertinoIcons.qrcode, Colors.lightBlueAccent,
                              () => RouteStateScope.of(context).go('/doorbells/$doorbellId/qr')),
                          const Padding(padding: EdgeInsets.all(5)),
                          StickerCard.fromIcon(CupertinoIcons.hexagon, Colors.cyan, () => {}),
                          const Padding(padding: EdgeInsets.all(5)),
                          StickerCard.fromIcon(CupertinoIcons.rectangle, Colors.green, () => {}),
                          const Padding(padding: EdgeInsets.all(5)),
                          StickerCard.fromIcon(CupertinoIcons.rectangle_expand_vertical, Colors.yellow, () => {}),
                          const Padding(padding: EdgeInsets.all(5)),
                          StickerCard.fromIcon(CupertinoIcons.doc_append, Colors.orange, () => {}),
                          const Padding(padding: EdgeInsets.all(5)),
                        ],
                      ))),
            ])),

            // EVENTS
            const SliverList(
                delegate: SliverChildListDelegate.fixed(<Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 20, top: 30, right: 5),
                  child: Text('Events', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400))),
            ])),

            CupertinoSliverRefreshControl(
              onRefresh: () async {
                await Future<void>.delayed(
                  const Duration(milliseconds: 1000),
                );
              },
            ),
            EventList(
              doorbellId: doorbellId,
              onShareCallback: _onShareDoorbell,
              onStickerCallback: () => _onStickerDoorbell(context),
            ),
          ])),
    ));
  }

  Future<void> _onShareDoorbell() async {
    print("SHARE DOORBELL: $doorbellId");
  }

  Future<void> _onStickerDoorbell(context) async {
    print("ON STICKER DOORBELL: $doorbellId");
    await RouteStateScope.of(context).go('/doorbells/$doorbellId/qr');
  }
}
