import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  Profile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate.fixed(<Widget>[
      Column(children: [
        Padding(padding: EdgeInsets.only(top: 150)),
        Text('Profile settings'),
        Padding(padding: EdgeInsets.only(top: 20)),
        TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            child: Text('Sign out')),
      ])
    ]));
  }
}
