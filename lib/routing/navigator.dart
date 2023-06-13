import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/presentation/screens/empty_screen.dart';

import '../presentation/screens/doorbell_edit_screen.dart';
import '../presentation/screens/doorbell_screen.dart';
import '../presentation/screens/invite_accepted_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/qrcode_screen.dart';
import '../presentation/screens/call_screen.dart';
import '../routing.dart';
import '../services/db/data_store.dart';
import '../widgets/fade_transition_page.dart';

class AppNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const AppNavigator({super.key, required this.navigatorKey});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _scaffoldKey = const ValueKey('App scaffold');
  final _doorbellDetailsKey = const ValueKey('Doorbell details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    var doorbellId = routeState.route.parameters['doorbellId'];
    var callAccessToken = routeState.route.parameters['accessToken'];
    var inviteId = routeState.route.parameters['inviteId'];

    if (routeState.data?['refresh'] != null) {
      DataStore.of(context).reloadData(true);
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display the /doorbells on a back
        if (route.settings is Page && (route.settings as Page).key == _doorbellDetailsKey) {
          routeState.go('/doorbells');
        }

        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/login')
          FadeTransitionPage<void>(key: _signInKey, child: LoginScreen())
        else if (pathTemplate == '/_wait') ...[
          FadeTransitionPage<void>(
              key: _scaffoldKey,
              child: FutureBuilder(
                future: routeState.data["future"],
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    RouteStateScope.of(context).go(routeState.data["destinationRouteFunc"](snapshot.data));
                  }
                  return EmptyScreen.white().withWaitingIndicator();
                },
              )),
        ] else ...[
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: const MainScreen(),
          ),
          // MaterialPage(
          //   key: _scaffoldKey,
          //   child: FutureBuilder(
          //       future: DataStore.of(context).reloadData(true),
          //       builder: (context, snapshot) {
          //         if (snapshot.hasData) routeState.go(routeState.data?['url'] != null ? routeState.data['url'] : '/doorbells');
          //         return EmptyScreen.white().withWaitingIndicator();
          //       }),
          // ),
          if (pathTemplate == '/doorbells/:doorbellId' && doorbellId != null)
            MaterialPage(
              key: _doorbellDetailsKey,
              child: DoorbellScreen(doorbellId: doorbellId),
            ),
          if (pathTemplate == '/doorbells/:doorbellId/qr' && doorbellId != null)
            MaterialPage(
              key: _doorbellDetailsKey,
              fullscreenDialog: true,
              child: QRCodeScreen(doorbellId: doorbellId),
            ),
          if (pathTemplate == '/doorbells/:doorbellId/edit' && doorbellId != null)
            MaterialPage(
              key: _doorbellDetailsKey,
              fullscreenDialog: true,
              child: DoorbellEditScreen(doorbellId: doorbellId),
            ),
          if (pathTemplate == '/doorbells/:doorbellId/ring/:accessToken' && callAccessToken != null && doorbellId != null)
            MaterialPage(
              key: _doorbellDetailsKey,
              fullscreenDialog: true,
              child: CallScreen(accessToken: callAccessToken, doorbellId: doorbellId),
            ),
          if (pathTemplate == '/doorbells/:doorbellId/join/:accessToken' && callAccessToken != null && doorbellId != null)
            MaterialPage(
              key: _doorbellDetailsKey,
              fullscreenDialog: true,
              child: CallScreen(accessToken: callAccessToken, doorbellId: doorbellId),
            ),
          if (pathTemplate == '/invite/accept/:inviteId' && inviteId != null)
            MaterialPage(
              key: _scaffoldKey,
              fullscreenDialog: true,
              child: InviteAcceptedScreen(inviteId: inviteId),
            ),
          if (pathTemplate == '/invite/accept/:inviteId' && inviteId != null)
            MaterialPage(
              key: _scaffoldKey,
              fullscreenDialog: true,
              child: InviteAcceptedScreen(inviteId: inviteId),
            ),
        ],
      ],
    );
  }
}
