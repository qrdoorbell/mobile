import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:qrdoorbell_mobile/data.dart';

import 'event_card.dart';

class EventList extends StatelessWidget {
  final Doorbell? doorbell;

  EventList({
    super.key,
    this.doorbell,
  });

  @override
  Widget build(BuildContext context) {
    var events = doorbell != null
        ? Provider.of<DataStore>(context).getDoorbellEvents(doorbell!.doorbellId)
        : Provider.of<DataStore>(context).allEvents;

    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      return EventCard(event: events[index]);
    }, childCount: events.length));
  }
}
