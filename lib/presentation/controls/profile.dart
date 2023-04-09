import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/data.dart';

import '../../routing.dart';

class Profile extends StatelessWidget {
  const Profile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate.fixed(<Widget>[
      Column(children: [
        const Padding(padding: EdgeInsets.only(top: 160)),
        Text(DataStore.of(context).currentUser?.displayName ?? "unknown user",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
        const Padding(padding: EdgeInsets.only(top: 40)),
        CupertinoButton.filled(child: const Text('Call screen mock'), onPressed: () => RouteStateScope.of(context).go('/call-mock')),
        const Padding(padding: EdgeInsets.only(top: 40)),
        CupertinoButton.filled(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Text('Sign out')),
      ])
    ]));
  }
}
