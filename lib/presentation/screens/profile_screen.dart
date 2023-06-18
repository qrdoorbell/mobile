import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data.dart';
import '../../routing/route_state.dart';
import '../../services/callkit_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var user = DataStore.of(context).currentUser;
    var userName = user?.displayName ?? "N/A";
    var shortName = user.getShortName();
    var avatarColor = user.getAvatarColor();
    return SliverList(
        delegate: SliverChildListDelegate.fixed(<Widget>[
      Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            const Padding(padding: EdgeInsets.only(top: 80)),
            CircleAvatar(
                backgroundColor: avatarColor,
                minRadius: 60,
                child: Text(
                  shortName,
                  textScaleFactor: 2,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )),
            const Padding(padding: EdgeInsets.only(top: 20)),
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
            const Padding(padding: EdgeInsets.only(top: 40)),
            CupertinoButton.filled(
                onPressed: () {
                  RouteStateScope.of(context).wait(FirebaseAuth.instance.signOut(), (p0) => "/login");
                },
                child: const Text('Sign out')),
            const Padding(padding: EdgeInsets.only(top: 40)),
            CupertinoButton.filled(
                onPressed: () {
                  RouteStateScope.of(context).go('/_test1');
                },
                child: const Text('Call Screen')),
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
