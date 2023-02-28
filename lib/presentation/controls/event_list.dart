import 'package:flutter/cupertino.dart';

class EventList extends StatelessWidget {
  EventList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate.fixed(<Widget>[
      Column(children: [
        Padding(padding: EdgeInsets.only(top: 150)),
        Text('Events list'),
      ])
    ]));
    // return Column(children: [
    //   Padding(padding: EdgeInsets.only(top: 150)),
    //   Text('Events list'),
    // ]);
  }
}
