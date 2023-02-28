import 'package:flutter/cupertino.dart';

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
      ])
    ]));
  }
}
