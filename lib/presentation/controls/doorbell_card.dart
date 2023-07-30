import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../services/db/firebase_repositories.dart';

import '../../data.dart';

typedef DoorbellCallback = void Function(Doorbell doorbell);

final Widget qrcodeSvg = Padding(
    padding: const EdgeInsets.only(top: 7, left: 4, right: 4),
    child: SvgPicture.asset(
      'assets/qrcode-blue.svg',
      fit: BoxFit.scaleDown,
    ));

class DoorbellCard extends StatefulWidget {
  final Doorbell doorbell;
  final String announce;
  final DoorbellCallback onTapHandler;

  const DoorbellCard({
    required this.doorbell,
    required this.announce,
    required this.onTapHandler,
  });

  @override
  State<DoorbellCard> createState() => _DoorbellCardState();
}

class _DoorbellCardState extends State<DoorbellCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.grey.shade100,
                  width: 1,
                )),
            shadowColor: Colors.grey.shade100,
            child: InkWell(
                onTap: () => widget.onTapHandler(widget.doorbell),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, left: 22, right: 16, bottom: 20),
                  child: Column(
                    children: [
                      SizedBox(
                          height: 90,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 55, child: qrcodeSvg),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(widget.doorbell.name, style: const TextStyle(fontSize: 24)),
                                        const Padding(padding: EdgeInsets.only(top: 9)),
                                        Text(
                                          widget.announce,
                                          style: const TextStyle(color: Colors.grey),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ])))
                            ],
                          )),
                      const Padding(padding: EdgeInsets.only(top: 30)),
                      Consumer<DoorbellUsersRepository>(builder: (context, repo, child) {
                        var avatars = repo.getDoorbellUsers(widget.doorbell.doorbellId);
                        var nonEmptyAvatars = avatars.where((x) => x.userShortName != "--").toList();
                        var emptyAvatarsCount = avatars.where((x) => x.userShortName == null || x.userShortName == "--").length;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // if (doorbell.settings.automaticStateSettings == null)
                            //   CupertinoButton(
                            //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                            //     color: CupertinoColors.systemBlue.withAlpha(25),
                            //     borderRadius: BorderRadius.circular(10),
                            //     child: const Text(
                            //       'Set silent mode time',
                            //       style: TextStyle(color: CupertinoColors.activeBlue, fontSize: 16),
                            //     ),
                            //     onPressed: () => RouteStateScope.of(context).go('/settings'),
                            //   ),
                            // if (doorbell.settings.automaticStateSettings != null)
                            //   CupertinoButton(
                            //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                            //     color: CupertinoColors.systemBlue.withAlpha(25),
                            //     borderRadius: BorderRadius.circular(10),
                            //     child: const Text(
                            //       'Set silent mode time',
                            //       style: TextStyle(color: CupertinoColors.activeBlue, fontSize: 16),
                            //     ),
                            //     onPressed: () => {},
                            //   ),
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
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text("+$emptyAvatarsCount",
                                      textScaleFactor: 1, style: const TextStyle(color: CupertinoColors.inactiveGray))),

                            const Spacer(),
                            CupertinoSwitch(
                              onChanged: (bool value) async {
                                widget.doorbell.settings.enablePushNotifications = value;
                                await DataStore.of(context).updateDoorbellSettings(widget.doorbell);
                                setState(() {});
                              },
                              value: widget.doorbell.settings.enablePushNotifications,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: Icon(
                                widget.doorbell.settings.enablePushNotifications ? CupertinoIcons.bell : CupertinoIcons.bell_slash,
                                color:
                                    widget.doorbell.settings.enablePushNotifications ? Colors.blue.shade700 : CupertinoColors.inactiveGray,
                                size: 28,
                              ),
                            )
                          ],
                        );
                      })
                    ],
                  ),
                ))));
  }
}
