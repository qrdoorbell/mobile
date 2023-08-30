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
    return FutureBuilder(
        future: DataStore.of(context).acceptInvite(inviteId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.warning('Failed to accept invite: ${snapshot.error}');
            return EmptyScreen.white()
                .withText('Failed to accept invite')
                .withButton('Back', () => RouteStateScope.of(context).go('/doorbells'));
          }

          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data is String) {
            Future.delayed(Duration.zero, () => RouteStateScope.of(context).go('/doorbells/${snapshot.data}'));
            return EmptyScreen.white()
                .withChild(const Text('Invite accepted'))
                .withButton('Back', () => RouteStateScope.of(context).go('/doorbells'));
          }

          return EmptyScreen.white().withWaitingIndicator();
        });
  }
}
