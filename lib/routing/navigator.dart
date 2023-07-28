import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../presentation/screens/profile_delete_screen.dart';
import '../presentation/screens/empty_screen.dart';
import '../presentation/screens/doorbell_edit_screen.dart';
import '../presentation/screens/doorbell_screen.dart';
import '../presentation/screens/doorbell_users_screen.dart';
import '../presentation/screens/invite_accepted_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/qrcode_screen.dart';
import '../presentation/screens/call_screen.dart';
import '../routing.dart';
import '../widgets/fade_transition_page.dart';

class AppNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const AppNavigator({super.key, required this.navigatorKey});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  static final logger = Logger('AppNavigator');

  final _signInKey = const ValueKey('Sign in');
  final _forgotPasswordKey = const ValueKey('Forgot password');
  final _waitScreenKey = const ValueKey('Wait screen');
  final _mainScreenKey = const ValueKey('Main screen');
  final _inviteScreenKey = const ValueKey('Invite screen');
  final _doorbellDetailsKey = const ValueKey('Doorbell details screen');
  final _doorbellDetailsEditKey = const ValueKey('Doorbell details editor screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    var doorbellId = routeState.route.parameters['doorbellId'];
    var callAccessToken = routeState.route.parameters['accessToken'];
    var inviteId = routeState.route.parameters['inviteId'];

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
        if (routeState.route.pathTemplate.startsWith('/login')) ...[
          FadeTransitionPage<void>(key: _signInKey, child: LoginScreen()),
          if (pathTemplate == '/login/forgot-password')
            MaterialPage(child: ForgotPasswordScreen(key: _forgotPasswordKey, email: routeState.data['email'])),
        ] else if (pathTemplate == '/invite/accept/:inviteId' && inviteId != null)
          MaterialPage(
            key: _inviteScreenKey,
            fullscreenDialog: true,
            child: InviteAcceptedScreen(inviteId: inviteId),
          )
        else ...[
          // path: /doorbells
          FadeTransitionPage<void>(
            key: _mainScreenKey,
            child: const MainScreen(),
          ),

          if (pathTemplate == '/profile/delete-account')
            MaterialPage(
              key: _inviteScreenKey,
              child: ProfileDeleteScreen(),
            ),

          // path: /doorbells/:doorbellId
          if (pathTemplate.startsWith('/doorbells/:doorbellId') && doorbellId != null) ...[
            MaterialPage(
              key: _doorbellDetailsKey,
              child: DoorbellScreen(doorbellId: doorbellId),
            ),
            if (pathTemplate == '/doorbells/:doorbellId/qr')
              MaterialPage(
                key: _doorbellDetailsEditKey,
                child: QRCodeScreen(doorbellId: doorbellId),
              ),
            if (pathTemplate == '/doorbells/:doorbellId/edit')
              MaterialPage(
                key: _doorbellDetailsEditKey,
                child: DoorbellEditScreen(doorbellId: doorbellId),
              ),
            if (pathTemplate == '/doorbells/:doorbellId/ring/:accessToken' && callAccessToken != null)
              MaterialPage(
                key: _doorbellDetailsEditKey,
                child: CallScreen(accessToken: callAccessToken, doorbellId: doorbellId),
              ),
            if (pathTemplate == '/doorbells/:doorbellId/join/:accessToken' && callAccessToken != null)
              MaterialPage(
                key: _doorbellDetailsEditKey,
                child: CallScreen(accessToken: callAccessToken, doorbellId: doorbellId),
              ),
            if (pathTemplate == '/doorbells/:doorbellId/users')
              MaterialPage(
                key: _doorbellDetailsEditKey,
                child: DoorbellUsersScreen(doorbellId: doorbellId),
              ),
          ],
        ],
        if (pathTemplate.endsWith('/_wait'))
          FadeTransitionPage<void>(
              key: _waitScreenKey,
              child: FutureBuilder(
                future: Future.any(<Future>[
                  routeState.data["future"],
                  Future.delayed(routeState.data["timeout"], () {
                    logger.warning('Wait timed out');
                    throw TimeoutException('Wait timed out');
                  })
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && routeState.data != null) {
                    if (snapshot.hasError) {
                      logger.shout('An async error occured!', snapshot.error);
                      RouteStateScope.of(context).go(routeState.data["errorRoute"] ?? "/doorbells");
                    } else {
                      var route = (routeState.data["destinationRouteFunc"] != null
                              ? routeState.data["destinationRouteFunc"](snapshot.data)
                              : null) ??
                          routeState.data["destinationRoute"] ??
                          routeState.data["errorRoute"] ??
                          routeState.route.path ??
                          "/doorbells";

                      logger.fine('Redirecting to: $route');
                      RouteStateScope.of(context).go(route);
                    }
                  }
                  return EmptyScreen.white().withWaitingIndicator();
                },
              ))
      ],
    );
  }
}
