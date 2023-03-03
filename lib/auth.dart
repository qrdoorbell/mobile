import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AppAuth extends ChangeNotifier {
  bool _signedIn = false;

  bool get signedIn => _signedIn;

  AppAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _signedIn = user != null;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _signedIn = false;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) => other is AppAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

class AppAuthScope extends InheritedNotifier<AppAuth> {
  const AppAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AppAuth of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppAuthScope>()!.notifier!;
}
