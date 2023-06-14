import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import '../screens/empty_screen.dart';
import '../../data.dart';
import '../../routing.dart';

class InviteAcceptedScreen extends StatelessWidget {
  static final logger = Logger('InviteAcceptedScreen');

  final String inviteId;

  const InviteAcceptedScreen({
    required this.inviteId,
  });

  @override
  Widget build(BuildContext context) {
    RouteStateScope.of(context).wait(DataStore.of(context).acceptInvite(inviteId), (doorbellId) => '/doorbells/$doorbellId');
    return EmptyScreen.white().withWaitingIndicator();
  }
}
