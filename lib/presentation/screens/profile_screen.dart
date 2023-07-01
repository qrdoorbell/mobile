import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../../data.dart';
import '../../routing/route_state.dart';
import '../../services/call_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _callId = const Uuid().v4();
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    var user = DataStore.of(context).currentUser;

    var userName = user?.displayName ?? "N/A";
    var shortName = user.getShortName();
    var avatarColor = user.getAvatarColor();

    var displayNameController = TextEditingController(text: userName);

    return SliverList(
        delegate: SliverChildListDelegate.fixed(<Widget>[
      CupertinoListTile(
          leading: CircleAvatar(
            radius: 33,
            backgroundColor: avatarColor,
            child: Text(shortName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
          ),
          leadingSize: 60,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          subtitle: Text(user!.email ?? "")),
      const Padding(padding: EdgeInsets.only(top: 20)),
      CupertinoListTile(
        title: CupertinoTextField(
          controller: displayNameController,
          prefix: const Text('Display Name'),
          decoration: const BoxDecoration(),
          textAlign: TextAlign.right,
          onTapOutside: (event) async {
            userName = displayNameController.text;
          },
        ),
      ),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10), child: Divider(height: 1, thickness: 1)),
      CupertinoListTile(
        title: const Text('App Version', style: TextStyle(color: CupertinoColors.inactiveGray)),
        trailing: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text("...", style: TextStyle(color: CupertinoColors.inactiveGray));
                if (snapshot.data == null) return const Text("-", style: TextStyle(color: CupertinoColors.inactiveGray));

                return Text("${snapshot.data?.version}", style: const TextStyle(color: CupertinoColors.inactiveGray));
              }),
        ),
      ),
      CupertinoListTile(
        title: const Text('User ID', style: TextStyle(color: CupertinoColors.inactiveGray)),
        trailing: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(user.userId, style: const TextStyle(color: CupertinoColors.inactiveGray)),
        ),
      ),
      const Padding(padding: EdgeInsets.only(top: 20)),
      Padding(
          padding: const EdgeInsets.all(18),
          child: CupertinoButton.filled(
              onPressed: () async {
                await RouteStateScope.of(context).wait(DataStore.of(context).updateUserDisplayName(userName), (_) => "/doorbells");
              },
              child: const Text('Save'))),
      const Padding(padding: EdgeInsets.only(top: 200)),
      Padding(
          padding: const EdgeInsets.all(18),
          child: CupertinoButton.filled(
              onPressed: () {
                RouteStateScope.of(context).wait(FirebaseAuth.instance.signOut(), (_) => "/login");
              },
              child: const Text('Sign out'))),
      if (kDebugMode) ...[
        Padding(
            padding: const EdgeInsets.all(18),
            child: CupertinoButton(color: CupertinoColors.systemTeal, onPressed: _onEmulateCall, child: const Text('Emulate call'))),
      ],
    ]));
  }

  void _onEmulateCall() {
    if (_i == 0) CallManager().addCallEvent(StartCallEvent(_callId, "doorbell1_id", "room1_id"));
    if (_i == 1) CallManager().addCallEvent(IncomingCallEvent(_callId, "call_token_bla_bla_bla"));
    if (_i == 2) CallManager().addCallEvent(AcceptCallEvent(_callId, "user_me_id"));
    if (_i == 3) CallManager().addCallEvent(DeclineCallEvent(_callId, "user_me_id"));
    if (_i == 4) CallManager().addCallEvent(EndCallEvent(_callId, "ok"));

    _i++;
    if (_i == 5) {
      _i = 0;
      _callId = const Uuid().v4();
    }
  }
}
