import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/data.dart';
import 'package:qrdoorbell_mobile/routing.dart';

class InviteAcceptedScreen extends StatelessWidget {
  final String inviteId;

  const InviteAcceptedScreen({
    required this.inviteId,
  });

  @override
  Widget build(BuildContext context) {
    var dataStore = DataStoreStateScope.of(context).dataStore;
    return FutureBuilder<String>(
        future: dataStore.acceptInvite(inviteId),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          String text;
          bool isSuccess = false;
          if (snapshot.hasData && !snapshot.hasError) {
            RouteStateScope.of(context).go('/doorbells/${snapshot.data.toString()}');
            text = "Adding the Doorbell...";
            isSuccess = true;
          } else {
            text = snapshot.error.toString();
          }

          return CupertinoPageScaffold(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(padding: const EdgeInsets.all(16), child: Text(text)),
            const Padding(padding: EdgeInsets.only(top: 40)),
            if (!isSuccess)
              CupertinoButton.filled(child: const Text('Home'), onPressed: () => RouteStateScope.of(context).go('/doorbells')),
          ]));
        });
  }
}
