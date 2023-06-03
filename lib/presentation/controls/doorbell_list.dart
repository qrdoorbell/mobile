import 'package:flutter/material.dart';
import '../../data.dart';
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
                        announce: data[index].lastEvent != null
                            ? "${data[index].lastEvent!.formattedName} ${data[index].lastEvent!.formattedDateTimeSingleLine}"
                            : 'No events',
                        onTapHandler: onTapHandler,
                      ),
                  childCount: data.length));
        });
  }
}
