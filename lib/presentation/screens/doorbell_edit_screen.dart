import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/routing.dart';

import '../../data.dart';

class DoorbellEditScreen extends StatelessWidget {
  final String doorbellId;

  const DoorbellEditScreen({super.key, required this.doorbellId});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => RouteStateScope.of(context).go('/doorbells/$doorbellId'),
            color: CupertinoColors.activeBlue,
          ),
        ),
        child: Container(
            color: CupertinoColors.systemGroupedBackground,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CupertinoButton(
                    color: CupertinoColors.destructiveRed,
                    onPressed: () async {
                      final route = RouteStateScope.of(context);
                      await DataStore.of(context).removeDoorbell(doorbellId);
                      route.go('/doorbells');
                    },
                    child: const Text(
                      'Remove Doorbell',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
              ]),
            ])));
  }
}
