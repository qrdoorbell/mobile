import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data.dart';
import '../../routing/route_state.dart';
import '../../services/call_emulator_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var user = DataStore.of(context).currentUser;
    var authUser = FirebaseAuth.instance.currentUser;

    var userName = user?.displayName ?? "N/A";
    var shortName = user.getShortName();
    var avatarColor = user.getAvatarColor();

    var displayNameController = TextEditingController(text: userName);

    return CupertinoPageScaffold(
      child: Container(
        color: CupertinoColors.systemGroupedBackground,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            CupertinoListTile(
                backgroundColor: CupertinoColors.systemBackground,
                padding: const EdgeInsets.only(left: 18, right: 18, top: 90, bottom: 15),
                title: Row(
                  children: [
                    // UserAccountAvatar(name: shortName, size: 60),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: avatarColor,
                      child: Text(shortName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                          Text(
                            user?.email ?? "",
                            style: const TextStyle(fontSize: 14, color: CupertinoColors.inactiveGray),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            CupertinoListSection.insetGrouped(
              header: const Text(
                'ACCOUNT',
                style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
              ),
              additionalDividerMargin: 5,
              children: [
                CupertinoListTile(
                  title: CupertinoTextField(
                    controller: displayNameController,
                    prefix: const Text('Display Name'),
                    decoration: const BoxDecoration(),
                    textAlign: TextAlign.right,
                    onTapOutside: (event) async {
                      if (userName != displayNameController.text) {
                        await RouteStateScope.of(context)
                            .wait(DataStore.of(context).updateUserDisplayName(displayNameController.text), destinationRoute: "/profile");
                      }
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Email status'),
                  trailing: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(authUser?.emailVerified == true ? 'verified' : 'not verified',
                        style: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14)),
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text(
                'APPLICATION',
                style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
              ),
              additionalDividerMargin: 5,
              children: [
                CupertinoListTile(
                  title: const Text('App Version'),
                  trailing: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Text("...", style: TextStyle(color: CupertinoColors.inactiveGray));
                          if (snapshot.data == null) return const Text("-", style: TextStyle(color: CupertinoColors.inactiveGray));

                          return Text("${snapshot.data?.version}",
                              style: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14));
                        }),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('User ID'),
                  trailing: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(user?.userId ?? "", style: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14)),
                  ),
                ),
                if (kDebugMode) ...[
                  TextButton(onPressed: CallEmulatorService().setNextCallState, child: const Text('Emulate call')),
                  // TextButton(
                  //     onPressed: () async =>
                  //         await FirebaseAuth.instance.currentUser?.updatePhotoURL('https://avatars.githubusercontent.com/u/2341158?v=4'),
                  //     child: const Text('Update Profile photo URL')),
                ],
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Center(
                      child: TextButton(
                          child: const Text(
                            'Delete account',
                            style: TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.normal),
                          ),
                          onPressed: () => RouteStateScope.of(context).go('/profile/delete-account'))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: CupertinoButton.filled(
                      onPressed: () {
                        RouteStateScope.of(context).wait(FirebaseAuth.instance.signOut(), destinationRoute: "/login");
                      },
                      child: const Text('Sign out')),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
