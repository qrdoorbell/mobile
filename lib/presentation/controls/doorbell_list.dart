import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../tools.dart';
import '../../presentation/screens/main_screen.dart';
import '../../data.dart';
import '../../routing.dart';
import '../../services/db/firebase_repositories.dart';
import 'doorbell_card.dart';

class DoorbellList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: DataStore.of(context).doorbells),
          ChangeNotifierProvider.value(value: (DataStore.of(context).doorbellUsers as DoorbellUsersRepository)),
          ChangeNotifierProvider.value(value: PeriodicChangeNotifier(const Duration(seconds: 10))),
        ],
        builder: (context, child) => Consumer<DataStoreRepository<Doorbell>>(builder: (context, doorbells, child) {
              if (doorbells.isLoaded && doorbells.items.isEmpty)
                return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text("Add your first doorbell", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      const Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 40, left: 20, right: 20),
                        child: Text("Generate QR code, print stickers, and share your doorbell with friends.",
                            style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                      ),
                      CupertinoButton.filled(
                          onPressed: () => context.findAncestorStateOfType<MainScreenState>()?.createDoorbell(),
                          child: const Text(
                            "Add Doorbell",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const Padding(padding: EdgeInsets.all(50))
                    ]));

              return Consumer<PeriodicChangeNotifier>(
                  builder: (context, value, child) => SliverList.list(
                      children: doorbells.items
                          .sortedByCompare(
                              (x) => x.lastEvent?.dateTime, (a, b) => a != null ? (a.isBefore(b ?? DateTime.now()) ? 1 : -1) : -1)
                          .map(
                            (x) => DoorbellCard(
                              doorbell: x,
                              announce: x.lastEvent != null
                                  ? "${x.lastEvent!.formattedName} ${x.lastEvent!.formattedDateTimeSingleLine}"
                                  : 'No events',
                              onTapHandler: (Doorbell doorbell) => RouteStateScope.of(context).go('/doorbells/${doorbell.doorbellId}'),
                            ),
                          )
                          .toList()));
            }));
  }
}
