import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:qrdoorbell_mobile/app_routes.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      headerBuilder: (context, constr, _) =>
          Padding(padding: const EdgeInsets.only(top: 20), child: Image.asset('assets/logo-app-01_512.png')),
      actions: [
        ForgotPasswordAction(
          ((context, email) {
            Navigator.of(context).pushNamed('/forgot-password', arguments: {'email': email});
          }),
        ),
        AuthStateChangeAction(
          ((context, state) {
            if (state is UserCreated || state is SignedIn) {
              var user = (state is SignedIn) ? state.user : (state as UserCreated).credential.user;
              if (user == null) {
                return;
              }
              if (!user.emailVerified && (state is UserCreated)) {
                user.sendEmailVerification();
              }
              if (state is UserCreated) {
                if (user.displayName == null && user.email != null) {
                  var defaultDisplayName = user.email!.split('@')[0];
                  user.updateDisplayName(defaultDisplayName);
                }
              }
              Navigator.pushReplacementNamed(context, Routes.home);
              // Navigator.of(context).pushNamedAndRemoveUntil('/', ((route) => false));
            }
          }),
        ),
      ],
    );
  }
}