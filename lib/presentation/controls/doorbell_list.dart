import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/data.dart';
import 'doorbell_card.dart';

class DoorbellList extends StatelessWidget {
  final DoorbellCallback onTapHandler;

  DoorbellList({
    super.key,
    required this.onTapHandler,
  });

  @override
  Widget build(BuildContext context) {
    final doorbells = DataStore.of(context).allDoorbells;
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => DoorbellCard(
                  doorbell: doorbells[index],
                  announce: DoorbellEventType.getString(doorbells[index].lastEvent?.eventType) ?? 'No new events',
                  onTapHandler: onTapHandler,
                ),
            childCount: doorbells.length));
  }
}
