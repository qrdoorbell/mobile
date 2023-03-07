import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/data.dart';

class Profile extends StatelessWidget {
  Profile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate.fixed(<Widget>[
      Column(children: [
        Padding(padding: EdgeInsets.only(top: 160)),
        Text(DataStore.of(context).currentUser?.displayName ?? "unknown user", style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Profile settings'),
        Padding(padding: EdgeInsets.only(top: 20)),
        CupertinoButton.filled(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text('Sign out')),
      ])
    ]));
  }
}
