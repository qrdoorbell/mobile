import 'dart:async';

import 'package:logging/logging.dart';
import 'package:nanoid/nanoid.dart';

import '../../data.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_repositories.dart';

class FirebaseDataStore extends DataStore {
  static final logger = Logger('FirebaseDataStore');

  String? _uid;
  UserAccount? _currentUser;
  final FirebaseDatabase db;
  final DoorbellEventsRepository _eventsRepository;
  final DoorbellsRepository _doorbellsRepository;

  FirebaseDataStore(this.db)
      : _eventsRepository = DoorbellEventsRepository(db),
        _doorbellsRepository = DoorbellsRepository(db);

  @override
  Future<void> setUid(String? uid) async {
    logger.info("FirebaseDataStore.setUid: uid=$uid");
    if (_uid != uid) await dispose();

    _uid = uid;
    await reloadData();
  }

  @override
  Future<void> reloadData({bool force = false}) async {
    logger.fine("FirebaseDataStore.reloadData: force=$force, _uid=$_uid");

    logger.info("FirebaseDataStore.reloadData: Reloading data for user: userId='$_uid'");
    try {
      if (_currentUser == null || force) _currentUser = UserAccount.fromSnapshot(await db.ref('users/$_uid').get());

      _subscribe();
    } catch (error) {
      logger.warning("FirebaseDataStore.reloadData: Unable to reload user data: uid=$_uid, force=$force", error);
    }
  }

  void _subscribe() {
    logger.fine("FirebaseDataStore._subscribe: _uid=$_uid");
    if (_uid == null) {
      return;
    }

    for (var doorbellId in _currentUser!.doorbells) {
      _doorbellsRepository.subscribeTo(doorbellId);
      _eventsRepository.subscribeTo(doorbellId);
    }
  }

  @override
  UserAccount? get currentUser => _currentUser;

  @override
  List<Doorbell> get doorbells => _doorbellsRepository.snapshot;

  @override
  Stream<List<Doorbell>> get doorbellsStream => _doorbellsRepository.stream;

  @override
  List<DoorbellEvent> get doorbellEvents => _eventsRepository.snapshot;

  @override
  Stream<List<DoorbellEvent>> get doorbellEventsStream => _eventsRepository.stream;

  @override
  void addDoorbellEvent(int eventType, String doorbellId, String stickerId) {
    _eventsRepository.addValues([DoorbellEvent.create(eventType, doorbellId, stickerId)]);
  }

  @override
  Future<void> dispose() async {
    logger.info("Firebase DataStore dispose");
    _currentUser = null;
    await _doorbellsRepository.dispose();
    await _eventsRepository.dispose();
  }

  @override
  Future<Doorbell> createDoorbell([String name = '']) async {
    if (name.isEmpty) name = "My ${_digitName(_doorbellsRepository.snapshot.length + 1)} doorbell";

    final doorbell = Doorbell(nanoid(10), name);

    await _doorbellsRepository.create(doorbell);
    return doorbell;
  }

  @override
  Future<void> updateDoorbell(Doorbell doorbell) async {
    await _doorbellsRepository.update(doorbell);
  }

  @override
  Future<UserAccount> createUser(UserAccount user) async {
    await db.ref('users/${user.userId}').set(user.toMap());
    return user;
  }

  @override
  Future<void> removeDoorbell(String doorbellId) async {
    await _doorbellsRepository.remove(doorbellId);
  }

  @override
  Future<Doorbell> updateDoorbellSettings(Doorbell doorbell) async {
    await db.ref('doorbells/${doorbell.doorbellId}').update({'settings': doorbell.settings.toMap()});
    return doorbell;
  }

  @override
  Future<Doorbell> updateDoorbellName(Doorbell doorbell) async {
    await db.ref('doorbells/${doorbell.doorbellId}').update({'name': doorbell.name});
    return doorbell;
  }
}

String? _digitName(int n) {
  switch (n) {
    case 1:
      return 'first';
    case 2:
      return 'second';
    case 3:
      return 'third';
    case 4:
      return 'fourth';
    case 5:
      return 'fifth';
    case 6:
      return 'sixth';
    case 7:
      return 'sevenths';
    case 8:
      return 'eights';
    case 9:
      return 'nines';
    default:
      return null;
  }
}
