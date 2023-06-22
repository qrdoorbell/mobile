import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrdoorbell_mobile/routing.dart';

import 'package:qrdoorbell_mobile/services/db/firebase_repositories.dart';

import '../../data.dart';

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
              middle: const Text('Shared with'),
            ),
            child: Container(
                color: CupertinoColors.systemGroupedBackground,
                child: ListView(scrollDirection: Axis.vertical, children: [
                  Consumer<DoorbellUsersRepository>(
                      builder: (context, doorbellUsers, child) => Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                            // GENERAL
                            CupertinoListSection.insetGrouped(
                                additionalDividerMargin: 6,
                                children: doorbellUsers
                                    .getDoorbellUsers(widget.doorbellId)
                                    .map<Widget>(
                                      (e) => CupertinoListTile(
                                        title: Text(e.userDisplayName ?? e.userId),
                                        leading: CircleAvatar(
                                            backgroundColor: e.userColor,
                                            minRadius: 20,
                                            child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Text(
                                                e.userShortName ?? "--",
                                                textScaleFactor: 1,
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            )),
                                      ),
                                    )
                                    .toList()),
                          ]))
                ]))));
  }
}
