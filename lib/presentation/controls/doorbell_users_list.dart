import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/db/firebase_repositories.dart';
import '../../routing.dart';
import '../../data.dart';
import '../screens/doorbell_screen.dart';

class DoorbellUsersList extends StatefulWidget {
  final String doorbellId;

  const DoorbellUsersList({
    Key? key,
    required this.doorbellId,
  });

  @override
  State<DoorbellUsersList> createState() => _DoorbellUsersListState();
}

class _DoorbellUsersListState extends State<DoorbellUsersList> {
  @override
  Widget build(BuildContext context) {
    var dataStore = DataStore.of(context);
    return ChangeNotifierProvider.value(
        value: dataStore.doorbellUsers as DoorbellUsersRepository,
        builder: (context, child) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoColors.white,
              padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
              leading: CupertinoNavigationBarBackButton(
                onPressed: () => {RouteStateScope.of(context).go("/doorbells/${widget.doorbellId}")},
                color: CupertinoColors.activeBlue,
              ),
              middle: const Text('Manage users'),
            ),
            child: Container(
                color: CupertinoColors.systemGroupedBackground,
                child: ListView(scrollDirection: Axis.vertical, children: [
                  Consumer<DoorbellUsersRepository>(
                      builder: (context, doorbellUsers, child) => Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                            // GENERAL
                            CupertinoListSection.insetGrouped(
                                additionalDividerMargin: 0,
                                children: doorbellUsers
                                    .getDoorbellUsers(widget.doorbellId)
                                    .map<Widget>(
                                      (e) => SizedBox(
                                        child: CupertinoListTile(
                                          title: Text(e.userDisplayName ?? e.userId),
                                          subtitle: Text(e.email ?? ""),
                                          additionalInfo: Text(
                                            e.role,
                                            textScaleFactor: 0.8,
                                          ),
                                          leading: CircleAvatar(
                                              backgroundColor: e.userColor,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Text(
                                                  e.userShortName ?? "--",
                                                  textScaleFactor: 1,
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                              )),
                                        ),
                                      ),
                                    )
                                    .toList()),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                              alignment: Alignment.topCenter,
                              onPressed: () async {
                                DoorbellScreen.shareDoorbell(context, dataStore.getDoorbellById(widget.doorbellId)!);
                              },
                              child: const Text('+ Invite user'),
                            )
                          ]))
                ]))));
  }
}
