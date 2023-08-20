import 'package:collection/collection.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_options.dart';
import '../../data.dart';
import '../../routing.dart';
import '../../tools.dart';
import '../controls/event_list.dart';
import '../controls/stickers/sticker_card.dart';
import '../controls/stickers/v1/sticker_icon.dart';
import 'empty_screen.dart';
import 'sticker_edit_screen.dart';

class DoorbellScreen extends StatefulWidget {
  static final logger = Logger('DoorbellScreen');

  final String doorbellId;

  const DoorbellScreen({
    Key? key,
    required this.doorbellId,
  }) : super(key: key);

  @override
  State<DoorbellScreen> createState() => _DoorbellScreenState();

  static Future<void> shareDoorbell(BuildContext context, Doorbell doorbell) async {
    print("SHARE DOORBELL: ${doorbell.doorbellId}");

    var dataStore = DataStore.of(context);
    var route = RouteStateScope.of(context);
    var invite = Invite.create(doorbell.doorbellId);
    print('Invite created: inviteId=$invite.id');

    try {
      var message = "${AppSettings.inviteApiUrl}/invite/accept/${invite.id}";
      var result = await Share.shareWithResult(message, subject: "Share ${doorbell.name}");

      if (result.status == ShareResultStatus.success) {
        route.wait((() async {
          await dataStore.saveInvite(invite);
          await dataStore.reloadData(false);
        })(), destinationRoute: "/doorbells/${doorbell.doorbellId}");
      }
    } catch (error) {
      DoorbellScreen.logger.shout('Share doorbell failed!', error);
    }
  }

  static Future<void> printSticker(Doorbell doorbell) async {
    print("PRINT DOORBELL STICKER: ${doorbell.doorbellId}");

    var imgResp = await HttpUtils.secureGet(Uri.parse('${AppSettings.apiUrl}/api/v1/doorbells/${doorbell.doorbellId}/qr/'));
    if (imgResp.statusCode != 200) {
      print('ERROR: unable to download image: responseCode=${imgResp.statusCode}');
      return;
    }

    Share.shareXFiles([XFile.fromData(imgResp.bodyBytes, mimeType: 'image/png')], subject: doorbell.name);
  }
}

class _DoorbellScreenState extends State<DoorbellScreen> {
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore.of(context);
    final doorbell = dataStore.getDoorbellById(widget.doorbellId);

    if (doorbell == null) {
      return FutureBuilder(
          builder: (context, snapshot) => EmptyScreen.white().withWaitingIndicator(), future: RouteStateScope.of(context).go('/doorbells'));
    }

    FloatingActionButton? floatButton;

    if (dataStore.doorbellEvents.items.any((x) => x.doorbellId == widget.doorbellId)) {
      floatButton =
          FloatingActionButton(onPressed: () => DoorbellScreen.shareDoorbell(context, doorbell), child: const Icon(CupertinoIcons.share));
    }

    var avatars = dataStore.getDoorbellUsers(widget.doorbellId);
    var nonEmptyAvatars = avatars.where((x) => x.userShortName != "--").toList();
    var emptyAvatarsCount = avatars.where((x) => x.userShortName == null || x.userShortName == "--").length;

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
                onPressed: () => RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}/edit'),
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
                CupertinoButton(
                    child: const Text('See all'),
                    onPressed: () async => {
                          // TODO: #12 implement me
                        })
              ]),
              Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: SizedBox(
                      height: 105,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          // DOORBELL QR CODE
                          StickerCard.fromIconData(CupertinoIcons.qrcode, Colors.grey,
                              () => RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}/qr')),

                          // STICKERS
                          for (var sticker in doorbell.stickers.sortedBy((element) => element.updated ?? element.created).reversed) ...[
                            const Padding(padding: EdgeInsets.all(5)),
                            StickerCard(
                                color: Colors.yellow,
                                onPressed: () async {
                                  var updatedSticker = await Navigator.of(context).push(CupertinoDialogRoute(
                                      context: context,
                                      builder: (context) {
                                        return StickerEditScreen(handler: sticker.handler, doorbellId: widget.doorbellId, sticker: sticker);
                                      }));

                                  setState(() {
                                    doorbell.stickers.removeWhere((x) => x.stickerId == updatedSticker.stickerId);
                                    doorbell.stickers.add(updatedSticker);
                                  });
                                },
                                child: StickerV1Icon(sticker: sticker)),
                          ],

                          // ADD STICKER (+)
                          const Padding(padding: EdgeInsets.all(15)),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: DottedBorder(
                              borderPadding: const EdgeInsets.all(2),
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(30),
                              color: Colors.grey.shade300,
                              dashPattern: const [8, 4],
                              strokeWidth: 2,
                              child: MaterialButton(
                                  padding: EdgeInsets.zero,
                                  minWidth: 96,
                                  onPressed: () async {
                                    var newSticker = await Navigator.of(context).push(CupertinoDialogRoute(
                                        context: context,
                                        builder: (context) {
                                          return StickerEditScreen(
                                              handler: 'sticker_v1', templateId: 'sticker_v1_horizontal', doorbellId: widget.doorbellId);
                                        }));

                                    if (newSticker != null) {
                                      setState(() {
                                        doorbell.stickers.add(newSticker);
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Center(
                                      child: Text('+',
                                          style: TextStyle(color: Colors.grey.shade400, fontSize: 40, fontWeight: FontWeight.w200)),
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ))),
            ])),

            // USERS
            SliverList(
                delegate: SliverChildListDelegate.fixed(<Widget>[
              Row(children: [
                const Padding(padding: EdgeInsets.only(left: 18, top: 30)),
                const Text('Shared with', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400)),
                const Spacer(),
                CupertinoButton(
                    child: const Text('Manage'), onPressed: () => {RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}/users')})
              ]),
              Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: SizedBox(
                      height: 45,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          for (var user in nonEmptyAvatars)
                            Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: CircleAvatar(
                                    backgroundColor: user.userColor,
                                    minRadius: 20,
                                    child: Text(user.userShortName ?? "--",
                                        textScaleFactor: 1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                          if (nonEmptyAvatars.isNotEmpty && emptyAvatarsCount > 0)
                            Padding(
                                padding: const EdgeInsets.only(left: 8, top: 15),
                                child: Text("+$emptyAvatarsCount",
                                    textScaleFactor: 1, style: const TextStyle(color: CupertinoColors.inactiveGray))),
                        ],
                      )))
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
                await RouteStateScope.of(context).wait(dataStore.reloadData(false));
              },
            ),
            EventList(
              doorbellId: widget.doorbellId,
              onShareDoorbellCallback: () => DoorbellScreen.shareDoorbell(context, doorbell),
              // onPrintStickerCallback: () => _printSticker(doorbell),
              onPrintStickerCallback: () => RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}/qr'),
            ),
          ])),
    ));
  }
}
