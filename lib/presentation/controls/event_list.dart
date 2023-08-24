import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data.dart';
import '../../tools.dart';
import 'event_card.dart';

class EventList extends StatefulWidget {
  final String? doorbellId;
  final VoidCallback? onShareDoorbellCallback;
  final VoidCallback? onCreateStickerCallback;

  const EventList({
    super.key,
    this.doorbellId,
    this.onShareDoorbellCallback,
    this.onCreateStickerCallback,
  });

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {
    var dataStore = DataStore.of(context);
    var data = (widget.doorbellId != null ? dataStore.getDoorbellEvents(widget.doorbellId!) : dataStore.doorbellEvents.items);
    if (data.isNotEmpty) {
      return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: DataStore.of(context).doorbellEvents),
            ChangeNotifierProvider.value(value: PeriodicChangeNotifier(const Duration(seconds: 10))),
          ],
          builder: (context, child) => Consumer<DataStoreRepository<DoorbellEvent>>(
              builder: (context, events, child) => Consumer<PeriodicChangeNotifier>(
                  builder: (context, _, child) => SliverList.list(
                      children: events.items
                          .where((x) => (widget.doorbellId != null && x.doorbellId == widget.doorbellId) || widget.doorbellId == null)
                          .map((x) => EventCard(
                                event: x,
                                showDoorbellLink: widget.doorbellId == null,
                              ))
                          .toList()))));
    } else {
      return SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No events", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 24)),
              const Padding(padding: EdgeInsets.all(5)),
              if (widget.doorbellId != null && dataStore.getDoorbellById(widget.doorbellId!)?.stickers.isEmpty == true) ...[
                const Padding(padding: EdgeInsets.all(20)),
                CupertinoButton.filled(
                    onPressed: widget.onCreateStickerCallback,
                    child: const Text(
                      "Create Sticker",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ],
              const Padding(padding: EdgeInsets.all(50)),
            ],
          ));
    }
  }
}
