import 'package:flutter/material.dart';

import '../../model/doorbell.dart';
import 'doorbell_card.dart';

class DoorbellCardViewModel {
  final Doorbell doorbell;
  String? announce;

  DoorbellCardViewModel({required this.doorbell, this.announce});
}

class DoorbellList extends StatelessWidget {
  final List<DoorbellCardViewModel> doorbells;

  DoorbellList({
    super.key,
    required this.doorbells,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) =>
                DoorbellCard(doorbell: doorbells[index].doorbell, announce: doorbells[index].announce ?? 'No new messages'),
            childCount: doorbells.length));
  }
}
