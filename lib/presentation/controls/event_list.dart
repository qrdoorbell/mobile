import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/data.dart';

import 'event_card.dart';

class EventList extends StatelessWidget {
  final String? doorbellId;
  final VoidCallback? onShareDoorbellCallback;
  final VoidCallback? onPrintStickerCallback;

  const EventList({
    super.key,
    this.doorbellId,
    this.onShareDoorbellCallback,
    this.onPrintStickerCallback,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DoorbellEvent>>(
        stream: DataStore.of(context).doorbellEventsStream,
        initialData: DataStore.of(context).doorbellEvents,
        builder: (BuildContext context, AsyncSnapshot<List<DoorbellEvent>> snapshot) {
          var data = !snapshot.hasData ? <DoorbellEvent>[] : snapshot.data!;
          if (doorbellId != null) data = data.where((x) => x.doorbellId == doorbellId).toList();

          if (data.isNotEmpty) {
            return SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => EventCard(
                          event: data[index],
                          showDoorbellLink: doorbellId == null,
                        ),
                    childCount: data.length));
          } else {
            return SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No events", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24)),
                    const Padding(padding: EdgeInsets.all(5)),
                    if (doorbellId != null)
                      Column(children: [
                        const Padding(padding: EdgeInsets.all(20)),
                        CupertinoButton.filled(
                            onPressed: onPrintStickerCallback,
                            child: const Text(
                              "Print Sticker",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ]),
                    const Padding(padding: EdgeInsets.all(50)),
                  ],
                ));
          }
        });
  }
}
