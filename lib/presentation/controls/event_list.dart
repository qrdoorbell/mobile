import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/data.dart';

import 'event_card.dart';

class EventList extends StatelessWidget {
  final String? doorbellId;

  const EventList({
    super.key,
    this.doorbellId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DoorbellEvent>>(
        stream: DataStore.of(context).doorbellEventsStream,
        initialData: DataStore.of(context).doorbellEvents,
        builder: (BuildContext context, AsyncSnapshot<List<DoorbellEvent>> snapshot) {
          var data = !snapshot.hasData ? <DoorbellEvent>[] : snapshot.data!;
          if (doorbellId != null) data = data.where((x) => x.doorbellId == doorbellId).toList();

          return SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) => EventCard(
                        event: data[index],
                        showDoorbellLink: doorbellId == null,
                      ),
                  childCount: data.length));
        });
  }
}
