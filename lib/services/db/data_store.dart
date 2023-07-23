import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../model/doorbell.dart';
import '../../model/doorbell_event.dart';
import '../../model/invite.dart';
import '../../model/user_account.dart';

abstract class DataStoreRepository<T> extends ChangeNotifier {
  final logger = Logger("DataStoreRepository<$T>");

  bool get isLoaded;

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

  Iterable<DoorbellEvent> getDoorbellEvents(String doorbellId);
  Iterable<DoorbellUser> getDoorbellUsers(String doorbellId);
  Doorbell? getDoorbellById(String doorbellId) => doorbells.items.firstWhereOrNull((x) => x.doorbellId == doorbellId);

  Future<Doorbell> createDoorbell();
  Future<void> updateDoorbell(Doorbell doorbell);
  Future<void> updateDoorbellName(Doorbell doorbell);
  Future<Doorbell> updateDoorbellSettings(Doorbell doorbell);
  Future<void> removeDoorbell(Doorbell doorbell);

  Future<void> saveInvite(Invite invite);
  Future<String> acceptInvite(String inviteId);

  Future<void> updateUserAccount(UserAccount user);
  Future<void> updateUserDisplayName(String displayName);
  Future<void> updateVoipPushToken(String? voipPushToken);
  Future<void> updateFcmPushToken(String? fcmPushToken);

  Future<void> setUid(String? uid);

  bool get isLoaded;
  Future<DataStore> get future;
  Future<void> reloadData(bool force);

  Future<void> startTransaction([String? name]);
  Future<void> endTransaction();

  @override
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
      return;
    }

    if (dataStore.currentUser?.userId != user!.uid) {
      await dataStore.setUid(user.uid);

      if (dataStore.currentUser == null) {
        await dataStore.updateUserAccount(UserAccount.fromUser(user));
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

extension DataStoreBuildContextExtensions on BuildContext {
  DataStore get dataStore => DataStore.of(this);
}

extension DataStoreExtensions on DataStore {
  Future<void> runTransaction(Future<void> Function() transaction) async {
    if (kDebugMode)
      await startTransaction(StackTrace.current.toString().split("\n")[1]);
    else
      await startTransaction();

    try {
      await transaction();
    } finally {
      await endTransaction();
    }
  }
}
