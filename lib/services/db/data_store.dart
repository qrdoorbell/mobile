import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import '../../model/doorbell.dart';
import '../../model/doorbell_event.dart';
import '../../model/invite.dart';
import '../../model/user_account.dart';

abstract class DataStoreRepository<T> extends ChangeNotifier {
  final logger = Logger("DataStoreRepository<$T>");

  Iterable<T> get items;

  Future<void> reload();

  @override
  Future<void> dispose() async {
    super.dispose();
    logger.fine("DataStoreRepository<$T>.dispose");
  }
}

abstract class DataStore extends ChangeNotifier {
  UserAccount? get currentUser;

  DataStoreRepository<Doorbell> get doorbells;
  DataStoreRepository<DoorbellEvent> get doorbellEvents;
  DataStoreRepository<DoorbellUser> get doorbellUsers;

  Iterable<DoorbellEvent> getDoorbellEvents(String doorbellId) => doorbellEvents.items.where((x) => x.doorbellId == doorbellId);
  Iterable<DoorbellUser> getDoorbellUsers(String doorbellId) => doorbellUsers.items.where((x) => x.doorbellId == doorbellId);
  Doorbell? getDoorbellById(String doorbellId) => doorbells.items.firstWhereOrNull((x) => x.doorbellId == doorbellId);

  Future<Doorbell> createDoorbell();
  Future<void> updateDoorbell(Doorbell doorbell);
  Future<void> updateDoorbellName(Doorbell doorbell);
  Future<Doorbell> updateDoorbellSettings(Doorbell doorbell);
  Future<void> removeDoorbell(Doorbell doorbell);

  Future<void> saveInvite(Invite invite);
  Future<String> acceptInvite(String inviteId);

  Future<UserAccount> createUser(UserAccount user);
  Future<void> setUid(String? uid);

  Future<DataStore> isDataAvailable();
  Future<void> reloadData(bool force);

  Future<void> dispose();

  static DataStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DataStoreStateScope>()!.notifier!.dataStore;
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

class DataStoreRepositoryState<T> extends InheritedNotifier<DataStoreRepository<T>> {
  const DataStoreRepositoryState({
    required super.notifier,
    required super.child,
    super.key,
  });
}

class DataStoreStateScope extends InheritedNotifier<DataStoreState> {
  const DataStoreStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static DataStoreState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DataStoreStateScope>()!.notifier!;
}
