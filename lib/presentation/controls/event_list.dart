import 'package:flutter/cupertino.dart';
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
    var events = doorbell != null ? DataStore.of(context).getDoorbellEvents(doorbell!.doorbellId) : DataStore.of(context).allEvents;

    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
      return EventCard(event: events[index]);
    }, childCount: events.length));
  }
}
