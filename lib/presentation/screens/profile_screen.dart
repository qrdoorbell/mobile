import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data.dart';
import '../../services/callkit_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var user = DataStore.of(context).currentUser;
    var userName = user?.displayName ?? "N/A";
    return SliverList(
        delegate: SliverChildListDelegate.fixed(<Widget>[
      Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            const Padding(padding: EdgeInsets.only(top: 80)),
            CircleAvatar(
                backgroundColor: UserAccount.getColorFromDisplayName(user?.displayName),
                minRadius: 60,
                child: Text(UserAccount.getShortName(user), textScaleFactor: 2)),
            const Padding(padding: EdgeInsets.only(top: 20)),
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
            const Padding(padding: EdgeInsets.only(top: 40)),
            CupertinoButton.filled(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign out')),
            const Padding(padding: EdgeInsets.only(top: 100)),
            Row(
              children: [
                const Text('Version:  ', style: TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("...");
                      if (snapshot.data == null) return const Text("-");

                      return Text("${snapshot.data?.version}");
                    }),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              children: [
                const Text('User ID:  ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(DataStoreStateScope.of(context).dataStore.currentUser?.userId ?? "-"),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('VoIP token:  ', style: TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder(
                    future: CallKitServiceScope.of(context).getVoipPushToken(),
                    builder: (context, snapshot) => Expanded(child: Text(snapshot.hasData ? snapshot.data ?? "-" : "..."))),
              ],
            ),
          ]))
    ]));
  }
}
