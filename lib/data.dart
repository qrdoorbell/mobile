import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/model/helpers/id_provider.dart';
import 'model/doorbell.dart';
import 'model/doorbell_event.dart';
import 'model/user_account.dart';

export 'model/doorbell.dart';
export 'model/doorbell_event.dart';
export 'model/sticker.dart';
export 'model/user_account.dart';
export 'model/invite.dart';

abstract class DataStore extends IdProvider {
  UserAccount? get currentUser;
  List<Doorbell> get doorbells;
  Stream<List<Doorbell>> get doorbellsStream;

  List<DoorbellEvent> get doorbellEvents;
  Stream<List<DoorbellEvent>> get doorbellEventsStream;

  List<DoorbellEvent> getDoorbellEvents(String doorbellId) => doorbellEvents.where((element) => element.doorbellId == doorbellId).toList();
  Doorbell? getDoorbellById(String doorbellId) => doorbells.firstWhereOrNull((element) => element.doorbellId == doorbellId);

  Future<Doorbell> createDoorbell();
  Future<void> updateDoorbell(Doorbell doorbell);
  Future<void> removeDoorbell(String doorbellId);
  Future<void> updateDoorbellName(Doorbell doorbell);
  Future<Doorbell> updateDoorbellSettings(Doorbell doorbell);

  Future<void> setUid(String? uid);
  Future<void> reloadData({bool force = false});
  Future<void> dispose();

  void addDoorbellEvent(int eventType, String doorbellId, String stickerId);

  static DataStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DataStoreStateScope>()!.notifier!.dataStore;

  Future<UserAccount> createUser(UserAccount user);
}

class DataStoreState extends ChangeNotifier {
  final DataStore dataStore;

  DataStoreState({
    required this.dataStore,
  }) {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    // FirebaseAuth.instance.userChanges().listen(_onUserChanges);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    print("DataStore: FirebaseAuth.onAuthStateChanged: user=$user");
    await _onUserChanges(user);
  }

  Future<void> _onUserChanges(User? user) async {
    print("DataStore: FirebaseAuth.onUserChanges: user=${user?.uid}, dataStore.currentUser=${dataStore.currentUser?.userId}");
    if (user?.uid == null) {
      await dataStore.setUid(null);

      notifyListeners();
    } else if (dataStore.currentUser == null || dataStore.currentUser!.userId != user!.uid) {
      try {
        await dataStore.setUid(user!.uid);
      } catch (e) {
        print(e);
      }

      if (dataStore.currentUser == null) {
        await dataStore.createUser(UserAccount.fromUser(user!));

        try {
          await dataStore.setUid(user.uid);
        } catch (e) {
          print(e);
        }

        if (dataStore.currentUser == null) {
          await FirebaseAuth.instance.signOut();
        }
      }

      notifyListeners();
    }
  }
}

class DataStoreStateScope extends InheritedNotifier<DataStoreState> {
  const DataStoreStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static DataStoreState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DataStoreStateScope>()!.notifier!;
}
