import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../../app_options.dart';
import '../../data.dart';
import '../../routing/route_state.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
        AppleProvider(),
        // GoogleProvider(clientId: GOOGLE_CLIENT_ID),
      ],
      auth: fa.FirebaseAuth.instance,
      headerBuilder: (context, constr, _) =>
          Padding(padding: const EdgeInsets.only(top: 20), child: Image.asset('assets/logo-app-01_512.png')),
      actions: [
        SignedOutAction(((context) async {
          var routeState = RouteStateScope.of(context);

          await DataStore.of(context).setUid(null);
          routeState.go('/login');
        })),
        AuthCancelledAction(((context) async {
          var routeState = RouteStateScope.of(context);

          await DataStore.of(context).setUid(null);
          routeState.go('/login');
        })),
        ForgotPasswordAction((context, email) {
          RouteStateScope.of(context).go('/login/forgot-password', data: {'email': email});
        }),
        AuthStateChangeAction(
          (context, state) async => await RouteStateScope.of(context).wait((() async {
            if (state is UserCreated || state is SignedIn) {
              var user = (state is SignedIn) ? state.user : (state as UserCreated).credential.user;
              if (user == null) {
                return;
              }

              var dataStore = DataStore.of(context);
              var displayName = user.displayName;

              if (state is UserCreated) {
                if (user.displayName == null && user.email != null) {
                  displayName = user.email!.split('@')[0];
                  await user.updateDisplayName(displayName);
                }

                var userAccount = UserAccount(userId: user.uid, displayName: displayName, email: user.email);
                await dataStore.updateUserAccount(userAccount);
              }

              if (!user.emailVerified && (state is UserCreated)) {
                await user.sendEmailVerification();
              }
            }
          })(), destinationRoute: '/doorbells', errorRoute: '/login'),
        ),
      ],
    );
  }
}
