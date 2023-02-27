import 'package:flutter/material.dart';

import '../../model/doorbell.dart';
import 'doorbell_list_item.dart';

class DoorbellCardViewModel {
  final Doorbell doorbell;
  String? announce;

  DoorbellCardViewModel({required this.doorbell, this.announce});
}

class DoorbellList extends StatelessWidget {
  final List<DoorbellCardViewModel> doorbells;

  DoorbellList({
    required this.doorbells,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: ListView.builder(
            itemCount: doorbells.length,
            itemBuilder: (context, index) => DoorbellListItem(
                  name: doorbells[index].doorbell.name,
                  announce: doorbells[index].announce ?? 'No new messages',
                )));
  }
}
