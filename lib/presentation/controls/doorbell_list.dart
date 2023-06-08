import 'package:collection/collection.dart';
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
    return FutureBuilder(
      future: dataStore.dataAvailable,
      builder: (context, snapshot) {
        var data = DataStore.of(context).doorbells
          ..sortByCompare((x) => x, (a, b) {
            if (a.lastEvent != null && b.lastEvent != null) return b.lastEvent!.dateTime.isAfter(a.lastEvent!.dateTime) ? 1 : -1;
            return a.name.compareTo(b.name);
          });
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
      },
    );
  }
}
