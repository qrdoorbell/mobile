import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import '../../data.dart';
import 'doorbell_card.dart';

class DoorbellList extends StatefulWidget {
  final DoorbellCallback onTapHandler;

  const DoorbellList({
    super.key,
    required this.onTapHandler,
  });

  @override
  State<DoorbellList> createState() => DoorbellListState();
}

class DoorbellListState extends State<DoorbellList> {
  @override
  Widget build(BuildContext context) {
    final dataStore = DataStore.of(context);
    var data = dataStore.doorbells.items.sortedByCompare((x) => x, (a, b) {
      if (a.lastEvent != null && b.lastEvent != null) return b.lastEvent!.dateTime.isAfter(a.lastEvent!.dateTime) ? 1 : -1;
      return a.name.compareTo(b.name);
    });
    return SliverList.list(
        children: data
            .map((x) => DoorbellCard(
                  doorbell: x,
                  announce: x.lastEvent != null ? "${x.lastEvent!.formattedName} ${x.lastEvent!.formattedDateTimeSingleLine}" : 'No events',
                  onTapHandler: widget.onTapHandler,
                ))
            .toList());
  }
}
