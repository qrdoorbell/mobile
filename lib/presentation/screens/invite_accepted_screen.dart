import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:qrdoorbell_mobile/data.dart';
import 'package:qrdoorbell_mobile/presentation/screens/empty_screen.dart';
import 'package:qrdoorbell_mobile/routing.dart';

class InviteAcceptedScreen extends StatelessWidget {
  static final logger = Logger('InviteAcceptedScreen');

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
          if (snapshot.hasData && !snapshot.hasError) {
            RouteStateScope.of(context).go('/doorbells/${snapshot.data.toString()}');
            return EmptyScreen.white("Adding the Doorbell...");
          } else {
            logger.shout('An error occured while processing share request', snapshot.error, snapshot.stackTrace);
            RouteStateScope.of(context).go('/doorbells/${snapshot.data.toString()}');

            return EmptyScreen.white("Error occured");
          }
        });
  }
}
