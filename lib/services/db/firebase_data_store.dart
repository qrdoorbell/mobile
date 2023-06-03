import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' show post;
import 'package:logging/logging.dart';
import 'package:nanoid/nanoid.dart';

import '../../data.dart';
import 'firebase_repositories.dart';

class FirebaseDataStore extends DataStore {
  static final logger = Logger('FirebaseDataStore');

  String? _uid;
  UserAccount? _currentUser;
  Completer<bool> _reloadCompleter = Completer<bool>();
  final FirebaseDatabase db;
  final DoorbellEventsRepository _eventsRepository;
  final DoorbellsRepository _doorbellsRepository;
  final Map<String, List<DoorbellUser>> _doorbellUsersCache = {};

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
  Future<bool> get dataAvailable => _reloadCompleter.future;

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

    var doorbells = _currentUser?.doorbells ?? [];
    if (doorbells.isEmpty) return;

    logger.fine('Doorbells to be loaded: $doorbells');

    _reloadCompleter = Completer<bool>();
    var sub = _doorbellsRepository.stream.listen((data) {
      if (doorbells.every((x) => data.any((y) => y.doorbellId == x))) {
        logger.fine('Doorbells to loaded (${data.length}): $data');
        _refreshDoorbellUsersCache().then((value) => {if (!_reloadCompleter.isCompleted) _reloadCompleter.complete(true)},
            onError: (error) => {if (!_reloadCompleter.isCompleted) _reloadCompleter.completeError(error)});
      }
    });

    Future.delayed(
        const Duration(seconds: 30),
        () =>
            {if (!_reloadCompleter.isCompleted) _reloadCompleter.completeError(TimeoutException('Error loading data from DB - timeout'))});

    await _reloadCompleter.future;
    sub.cancel();
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

  Future<void> _refreshDoorbellUsersCache() async {
    logger.fine('Cleanup DoorbellUsers cache');
    _doorbellUsersCache.clear();

    for (var doorbellId in _currentUser!.doorbells) {
      var records = await db.ref('doorbell-users/$doorbellId').get();
      _doorbellUsersCache[doorbellId] = <DoorbellUser>[
        ...records.children.map((x) => DoorbellUser(doorbellId: doorbellId, userId: x.key!, role: (x.value as Map)['role']))
      ];
    }

    var displayNames = {};
    var uids = _doorbellUsersCache.values.map((x) => x.map((e) => e.userId)).flattened.toSet();
    var dataLoaders = Map.fromEntries(
        uids.map((uid) => MapEntry(uid, db.ref('users/$uid/displayName').get().then((v) => displayNames[uid] = v.value?.toString()))));

    logger.fine('Loading user display names from DB');
    if (logger.isLoggable(Level.FINEST)) logger.finest('User ids: $uids');

    await Future.wait(dataLoaders.values);

    logger.finest('Update DoorbellUsers cache');
    _doorbellUsersCache.forEach((doorbellId, doorbellUsers) {
      for (var user in doorbellUsers) {
        user.userDisplayName = displayNames[user.userId] ?? "";
        user.userShortName = UserAccount.getShortNameFromDisplayName(user.userDisplayName);
      }
    });

    logger.fine('DoorbellUsers cache reload complete!');
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
  Future<void> removeDoorbell(Doorbell doorbell) async {
    await _doorbellsRepository.remove(doorbell);
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

  @override
  Future<String> acceptInvite(String inviteId) async {
    logger.info("Accept Doorbell invite: id='$inviteId'");

    var jwtToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (jwtToken == null) throw AssertionError('Cannot get JWT token');

    var resp = await post(Uri.https('j.qrdoorbell.io', '/invite/accept/$inviteId'), headers: {'Authorization': 'Bearer $jwtToken'});
    if (resp.statusCode != 200) {
      logger.warning('Failed to accept Doorbell Invite - API returned an error: ${resp.body}');
      throw AssertionError('Failed to accept Doorbell Invite - API returned an error: ${resp.body}');
    }

    await reloadData(force: true);
    return resp.body; // doorbellId
  }

  @override
  Future<void> saveInvite(Invite invite) async {
    await db.ref('invites/${invite.id}').set(invite.toMap());
  }

  @override
  List<DoorbellUser> getDoorbellUsers(String doorbellId) => _doorbellUsersCache[doorbellId] ?? [];
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
