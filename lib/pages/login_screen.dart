import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Timy", style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(40.0),
              child: _LoginForm(),
            ),
            // PrivacySettingsButton(),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();

  @override
  void dispose() {
    // Suggested to be disposed: https://flutter.dev/docs/cookbook/forms/retrieve-input#1-create-a-texteditingcontroller
    _userTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    submitCallback() {
      // if (_formKey.currentState?.validate() ?? false) {
      //   // loginUser(EmailAuthProvider.credential(email: _userTextEditingController.text, password: _passwordTextEditingController.text));

      //   final loginAction = EmailPasswordLoginAction(email: _userTextEditingController.text, password: _passwordTextEditingController.text);

      //   StoreProvider.of<AppState>(context).dispatch(loginAction);
      //   Scaffold.of(context).showSnackBar(SnackBar(content: Text("Logging you in...")));

      //   loginAction.completer.future.catchError((error) {
      //     Scaffold.of(context).hideCurrentSnackBar();
      //     Logger.w(error.code.toString());
      //     Scaffold.of(context)
      //         .showSnackBar(SnackBar(content: Text(CirclesLocalizations.of(context).authErrorMessage(error.code.toString()))));
      //   });
      // }
    }

    final submitButton = TextButton(onPressed: submitCallback, child: Text("Login"));

    final _userTextField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: "Email"),
      controller: _userTextEditingController,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return "Please enter your email";
        }
        return null;
      },
    );

    final _passwordTextField = TextFormField(
      decoration: const InputDecoration(labelText: "Password"),
      controller: _passwordTextEditingController,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return "Please enter your password";
        }
        return null;
      },
      obscureText: true,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[_userTextField, _passwordTextField, submitButton],
      ),
    );
  }
}
