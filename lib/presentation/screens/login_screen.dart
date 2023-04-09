import 'package:firebase_auth/firebase_auth.dart' as FA;
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
        GoogleProvider(clientId: GOOGLE_CLIENT_ID),
      ],
      auth: FA.FirebaseAuth.instance,
      headerBuilder: (context, constr, _) =>
          Padding(padding: const EdgeInsets.only(top: 20), child: Image.asset('assets/logo-app-01_512.png')),
      actions: [
        ForgotPasswordAction(
          ((context, email) {
            Navigator.of(context).pushNamed('/forgot-password', arguments: {'email': email});
          }),
        ),
        AuthStateChangeAction(
          ((context, state) async {
            if (state is UserCreated || state is SignedIn) {
              var user = (state is SignedIn) ? state.user : (state as UserCreated).credential.user;
              if (user == null) {
                return;
              }

              var routeState = RouteStateScope.of(context);
              if (!user.emailVerified && (state is UserCreated)) {
                user.sendEmailVerification();
              }
              if (state is UserCreated) {
                if (user.displayName == null && user.email != null) {
                  var defaultDisplayName = user.email!.split('@')[0];
                  user.updateDisplayName(defaultDisplayName);
                }

                await DataStore.of(context).createUser(UserAccount.fromUser(user));
              }

              await routeState.go('/doorbells');
            }
          }),
        ),
      ],
    );
  }
}
