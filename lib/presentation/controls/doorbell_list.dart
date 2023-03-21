import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/data.dart';
import 'doorbell_card.dart';

class DoorbellList extends StatelessWidget {
  final DoorbellCallback onTapHandler;

  const DoorbellList({
    super.key,
    required this.onTapHandler,
  });

  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore.of(context);
    return StreamBuilder<List<Doorbell>>(
        stream: dataStore.doorbellsStream,
        initialData: dataStore.doorbells,
        builder: (BuildContext context, AsyncSnapshot<List<Doorbell>> snapshot) {
          var data = !snapshot.hasData ? <Doorbell>[] : snapshot.data!;
          return SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) => DoorbellCard(
                        doorbell: data[index],
                        announce: DoorbellEventType.getString(data[index].lastEvent?.eventType) ?? 'No new events',
                        onTapHandler: onTapHandler,
                      ),
                  childCount: data.length));
        });
  }
}
