import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/model/helpers/id_provider.dart';
import 'model/doorbell.dart';
import 'model/doorbell_event.dart';
import 'model/sticker.dart';
import 'model/user_account.dart';

export 'model/doorbell.dart';
export 'model/doorbell_event.dart';
export 'model/sticker.dart';
export 'model/user_account.dart';

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

  Future<void> setUid(String? uid);
  Future<void> reloadData();
  Future<void> dispose();

  void addDoorbellEvent(int eventType, String doorbellId, String stickerId);

  static DataStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DataStoreStateScope>()!.notifier!.dataStore;
}

class DataStoreState extends ChangeNotifier {
  String? _uid;
  final DataStore dataStore;

  DataStoreState({
    required this.dataStore,
  }) {
    _uid = FirebaseAuth.instance.currentUser?.uid;
    FirebaseAuth.instance.userChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user?.uid == null) {
      _uid = null;
      await dataStore.setUid(null);

      notifyListeners();
    } else if (_uid != user?.uid) {
      _uid = user?.uid;
      try {
        await dataStore.setUid(_uid);
      } catch (e) {
        print(e);
      }

      if (dataStore.currentUser == null) {
        FirebaseAuth.instance.signOut();
      }

      notifyListeners();
    } else {
      try {
        await dataStore.setUid(_uid);
      } catch (e) {
        print(e);
      }

      if (dataStore.currentUser == null) {
        FirebaseAuth.instance.signOut();
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
