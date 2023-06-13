import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../data.dart';
import '../../services/db/firebase_repositories.dart';
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
    // final dataStore = DataStore.of(context);
    // var data = dataStore.doorbells.items.sortedByCompare((x) => x, (a, b) {
    //   if (a.lastEvent != null && b.lastEvent != null) return b.lastEvent!.dateTime.isAfter(a.lastEvent!.dateTime) ? 1 : -1;
    //   return a.name.compareTo(b.name);
    // });
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: DataStore.of(context).doorbells),
          ChangeNotifierProvider.value(value: (DataStore.of(context).doorbellUsers as DoorbellUsersRepository)),
        ],
        builder: (context, child) => Consumer<DataStoreRepository<Doorbell>>(
            builder: (context, doorbells, child) => SliverList.list(
                children: doorbells.items
                    .map((x) => DoorbellCard(
                          doorbell: x,
                          announce: x.lastEvent != null
                              ? "${x.lastEvent!.formattedName} ${x.lastEvent!.formattedDateTimeSingleLine}"
                              : 'No events',
                          onTapHandler: widget.onTapHandler,
                        ))
                    .toList())));
  }
}
