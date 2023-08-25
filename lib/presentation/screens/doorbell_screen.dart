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
import '../../services/sticker_handler_factory.dart';
import '../../tools.dart';
import '../controls/event_list.dart';
import '../controls/stickers/sticker_card.dart';
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
      body: CustomScrollView(slivers: <Widget>[
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
          const Padding(
              padding: EdgeInsets.only(left: 18, top: 10, bottom: 10),
              child: Text('Stickers for print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400))),
          SizedBox(
              width: double.infinity,
              height: 104,
              child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[
                const Padding(padding: EdgeInsets.only(left: 15)),

                // DOORBELL QR CODE
                StickerCard.fromIconData(
                    CupertinoIcons.qrcode, Colors.grey, () => RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}/qr')),

                // STICKERS
                const Padding(padding: EdgeInsets.only(left: 15)),
                for (var sticker in doorbell.stickers.sortedBy((element) => element.updated ?? element.created).reversed) ...[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: StickerHandlerFactory.getStickerIconWidget(sticker, () async => await onStickerIconTap(doorbell, sticker))),
                ],

                // ADD STICKER (+)
                const Padding(padding: EdgeInsets.only(left: 15)),
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
                            onPressed: () async => await onStickerAddTap(doorbell),
                            child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Center(
                                    child: Text('+',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w200,
                                        ))))))),
                const Padding(padding: EdgeInsets.only(left: 15)),
              ])),
        ])),

        // USERS
        SliverList(
            delegate: SliverChildListDelegate.fixed(<Widget>[
          const Padding(padding: EdgeInsets.only(top: 15)),
          Row(children: [
            const Padding(padding: EdgeInsets.only(left: 18)),
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
          onCreateStickerCallback: () => onStickerAddTap(doorbell),
        ),
      ]),
    ));
  }

  static Future<T?> _showStickerEditScreenModal<T>({required BuildContext context, required WidgetBuilder builder}) async {
    return await showModalBottomSheet<T>(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      enableDrag: false,
      showDragHandle: false,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: false,
      clipBehavior: Clip.hardEdge,
      isDismissible: false,
      elevation: 10,
      context: context,
      builder: builder,
    );
  }

  Future<void> onStickerIconTap(Doorbell doorbell, StickerInfo sticker) async {
    await _showStickerEditScreenModal(
        context: context,
        builder: (context) => StickerEditScreen(handler: sticker.handler, doorbellId: widget.doorbellId, sticker: sticker));

    if (sticker.data.isChanged) {
      setState(() {
        doorbell.stickers.removeWhere((x) => x.stickerId == sticker.stickerId);
        doorbell.stickers.insert(0, sticker);
      });
    }
  }

  Future<void> onStickerAddTap(Doorbell doorbell) async {
    var newSticker = await _showStickerEditScreenModal(
        context: context,
        builder: (context) => StickerEditScreen(handler: 'sticker_v1', templateId: 'sticker_v1_vertical', doorbellId: widget.doorbellId));

    if (newSticker != null) {
      setState(() {
        doorbell.stickers.add(newSticker);
      });
    }
  }
}
