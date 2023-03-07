import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AppAuth extends ChangeNotifier {
  String? _uid;

  bool get signedIn => _uid != null;
  String? get uid => _uid;

  AppAuth() {
    _uid = FirebaseAuth.instance.currentUser?.uid;

    FirebaseAuth.instance.userChanges().listen((User? user) {
      _uid = user?.uid;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _uid = null;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) => other is AppAuth && other._uid == _uid;

  @override
  int get hashCode => _uid.hashCode;
}

class AppAuthScope extends InheritedNotifier<AppAuth> {
  const AppAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AppAuth of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppAuthScope>()!.notifier!;
}
