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
  final DoorbellCallback onTapHandler;

  DoorbellList({
    super.key,
    required this.doorbells,
    required this.onTapHandler,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => DoorbellCard(
                  doorbell: doorbells[index].doorbell,
                  announce: doorbells[index].announce ?? 'No new messages',
                  onTapHandler: onTapHandler,
                ),
            childCount: doorbells.length));
  }
}
