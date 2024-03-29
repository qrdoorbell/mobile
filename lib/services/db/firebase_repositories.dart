import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';

import '../../data.dart';

abstract class FirebaseRepository<T> extends DataStoreRepository<T> {
  final _items = <T>[];
  final DataStore dataStore;

  @override
  bool get isLoaded => this.dataStore.isLoaded;

  @override
  Iterable<T> get items => _items;

  FirebaseRepository(this.dataStore);

  @override
  Future<void> reload();

  void clear() {
    _items.clear();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    logger.fine("FirebaseRepository<$T>.dispose");
  }
}

class DoorbellsRepository extends FirebaseRepository<Doorbell> {
  final FirebaseDatabase db;

  DoorbellsRepository(this.db, super.dataStore);

  Future<void> update(Doorbell doorbell) async {
    await dataStore.runTransaction(() async {
      await db.ref('doorbells/${doorbell.doorbellId}').set(doorbell.toMap());
    });
    notifyListeners();
  }

  @override
  Future<void> reload() async {
    _items.clear();

    await dataStore.runTransaction(() async {
      var loaders = <Future<Doorbell?>>[];
      for (var doorbellId in dataStore.currentUser!.doorbells) {
        loaders.add(_loadOne(db.ref('doorbells/$doorbellId').get()));
      }

      var doorbells = (await Future.wait(loaders)).whereNotNull();
      _items.addAll(doorbells);
    });

    notifyListeners();
  }

  Doorbell add(Doorbell doorbell) {
    _items.add(doorbell);
    notifyListeners();

    return _items.where((x) => x.doorbellId == doorbell.doorbellId).single;
  }

  Future<Doorbell?> _loadOne(Future<DataSnapshot> snapshotLoader) async {
    var snapshot = await snapshotLoader;
    if (!snapshot.exists) return null;

    return Doorbell.fromSnapshot(snapshot);
  }
}

class DoorbellEventsRepository extends FirebaseRepository<DoorbellEvent> {
  final FirebaseDatabase db;
  final DoorbellsRepository doorbellsRepository;

  DoorbellEventsRepository(this.db, this.doorbellsRepository) : super(doorbellsRepository.dataStore) {
    doorbellsRepository.addListener(() {
      notifyListeners();
    });
  }

  Iterable<DoorbellEvent> getDoorbellEvents(String doorbellId) => _items.where((x) => x.doorbellId == doorbellId);

  @override
  Future<void> reload() async {
    _items.clear();

    await dataStore.runTransaction(() async {
      for (var doorbell in doorbellsRepository.items) {
        var events = await db.ref('doorbell-events/${doorbell.doorbellId}').get();
        _items.addAll(events.children.map((x) => DoorbellEvent.fromMap(x.value as Map)).whereNotNull());
      }

      _items.sortByCompare((x) => x.dateTime, (a, b) => a.isBefore(b) ? 1 : -1);
    });

    notifyListeners();
  }
}

class DoorbellUsersRepository extends FirebaseRepository<DoorbellUser> {
  final FirebaseDatabase db;
  final DoorbellsRepository doorbellsRepository;

  DoorbellUsersRepository(this.db, this.doorbellsRepository) : super(doorbellsRepository.dataStore) {
    doorbellsRepository.addListener(() {
      notifyListeners();
    });
  }

  Iterable<DoorbellUser> getDoorbellUsers(String doorbellId) => _items
      .where((x) => x.doorbellId == doorbellId)
      .sortedByCompare((x) => x.userShortName ?? "--", (a, b) => b[0] == '-' ? -1 : a.compareTo(b));

  @override
  Future<void> reload() async {
    logger.fine('Reload DoorbellUsers');
    _items.clear();

    await dataStore.runTransaction(() async {
      var loaders = <Future<void>>[];
      for (var doorbell in doorbellsRepository.items) {
        loaders.add(_loadOne(doorbell.doorbellId, db.ref('doorbell-users/${doorbell.doorbellId}').get()));
      }

      await Future.wait(loaders);

      var displayNames = {};
      var emails = {};
      var uids = _items.map((x) => x.userId).toSet();

      logger.fine('Loading user display names from DB');
      var userDataLoaders = Map.fromEntries(uids.map((uid) => MapEntry(
          uid,
          Future.wait([
            db.ref('users/$uid/displayName').get().then((v) => displayNames[uid] = v.value?.toString()),
            db.ref('users/$uid/email').get().then((v) => emails[uid] = v.value?.toString())
          ]))));

      if (logger.isLoggable(Level.FINEST)) logger.finest('User ids: $uids');
      await Future.wait(userDataLoaders.values);

      logger.finest('Update DoorbellUsers cache');
      for (var doorbellUser in _items) {
        if (displayNames.containsKey(doorbellUser.userId)) {
          doorbellUser.userDisplayName = displayNames[doorbellUser.userId] ?? "";
          doorbellUser.email = emails[doorbellUser.userId] ?? "";
          doorbellUser.userShortName = UserAccount.getShortNameFromDisplayName(doorbellUser.userDisplayName);
          doorbellUser.userColor = UserAccount.getColorFromShortName(doorbellUser.userShortName!);
        }
      }
    });

    logger.fine('DoorbellUsers cache reload complete!');

    notifyListeners();
  }

  Future<void> _loadOne(String doorbellId, Future<DataSnapshot> snapshotLoader) async {
    var snapshot = await snapshotLoader;
    if (!snapshot.exists || snapshot.key == null || snapshot.value == null) return;

    (snapshot.value! as Map).forEach((key, value) {
      if (value?['role'] != null) _items.add(DoorbellUser(doorbellId: doorbellId, userId: key, role: value['role']));
    });
  }
}
