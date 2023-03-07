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
        Text(DataStore.of(context).currentUser?.displayName ?? "unknown user", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
        Padding(padding: EdgeInsets.only(top: 40)),
        CupertinoButton.filled(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text('Sign out')),
      ])
    ]));
  }
}
