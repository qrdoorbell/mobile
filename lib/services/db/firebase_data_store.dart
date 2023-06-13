import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'package:qrdoorbell_mobile/app_options.dart';

import '../../data.dart';
import '../../tools.dart';
import 'firebase_repositories.dart';

class FirebaseDataStore extends DataStore {
  static final logger = Logger('FirebaseDataStore');

  String? _uid;
  UserAccount? _currentUser;
  Completer<DataStore> _reloadCompleter = Completer<DataStore>();
  final FirebaseDatabase db;
  late final DoorbellEventsRepository _eventsRepository;
  late final DoorbellUsersRepository _doorbellUsersRepository;
  late final DoorbellsRepository _doorbellsRepository;

  FirebaseDataStore(this.db) {
    _reloadCompleter.complete(this);
    _doorbellsRepository = DoorbellsRepository(db, this);
    _eventsRepository = DoorbellEventsRepository(db, _doorbellsRepository);
    _doorbellUsersRepository = DoorbellUsersRepository(db, _doorbellsRepository);
  }

  @override
  Future<void> setUid(String? uid) async {
    logger.info("FirebaseDataStore.setUid: uid=$uid");
    if (_uid != uid) {
      _uid = uid;

      if (uid != null) {
        await reloadData(true);
      } else {
        _clearData();
      }
    }
  }

  @override
  Future<DataStore> isDataAvailable() => _reloadCompleter.future;

  @override
  Future<void> reloadData(bool force) async {
    logger.fine("FirebaseDataStore.reloadData: force=$force, _uid=$_uid");
    logger.info("FirebaseDataStore.reloadData: Reloading data for user: userId='$_uid'");

    if (!_reloadCompleter.isCompleted) {
      logger.warning('Reload already in progress!');
      await _reloadCompleter.future;
      return;
    }

    await db.goOnline();

    if (_currentUser == null || force) {
      _currentUser = UserAccount.fromSnapshot(await db.ref('users/$_uid').get());
    }

    var doorbells = _currentUser?.doorbells ?? [];
    if (doorbells.isEmpty) return;

    logger.finest('Doorbells to be loaded: $doorbells');

    _reloadCompleter = Completer<DataStore>();
    notifyListeners();
    Future.delayed(
        const Duration(seconds: 30),
        () =>
            {if (!_reloadCompleter.isCompleted) _reloadCompleter.completeError(TimeoutException('Error loading data from DB - timeout'))});

    Future.wait([
      _doorbellsRepository.reload().then((_) => Future.wait([
            _doorbellUsersRepository.reload(),
            _eventsRepository.reload(),
          ])),
    ]).then((_) => _reloadCompleter.complete(this));

    await _reloadCompleter.future.timeout(const Duration(seconds: 10));
    await db.goOffline();

    logger.info('Firebase DataStore reload complete!');
  }

  @override
  UserAccount? get currentUser => _currentUser;

  @override
  DoorbellsRepository get doorbells => _doorbellsRepository;

  @override
  DoorbellEventsRepository get doorbellEvents => _eventsRepository;

  @override
  DoorbellUsersRepository get doorbellUsers => _doorbellUsersRepository;

  @override
  Iterable<DoorbellUser> getDoorbellUsers(String doorbellId) => _doorbellUsersRepository.getDoorbellUsers(doorbellId);

  @override
  Iterable<DoorbellEvent> getDoorbellEvents(String doorbellId) => _eventsRepository.getDoorbellEvents(doorbellId);

  @override
  Future<void> dispose() async {
    logger.info("Firebase DataStore dispose");
    await _doorbellsRepository.dispose();
    await _eventsRepository.dispose();
    await _doorbellUsersRepository.dispose();
    _currentUser = null;

    super.dispose();
  }

  @override
  Future<Doorbell> createDoorbell([String name = '']) async {
    logger.info("Create Doorbell: name='$name'");

    var resp = await HttpUtils.securePost(Uri.parse('$QRDOORBELL_API_URL/api/v1/doorbells/create'), body: {'doorbellName': name});
    if (resp.statusCode != 200) {
      logger.warning('Failed to accept Doorbell Invite - API returned an error: ${resp.body}');
      throw AssertionError('Failed to remove Doorbell - API returned an error: ${resp.body}');
    }

    var doorbell = Doorbell.fromMap(json.decode(resp.body));
    doorbells.add(doorbell);

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
    logger.info("Remove Doorbell: doorbellId='${doorbell.doorbellId}'");

    var resp =
        await HttpUtils.securePost(Uri.parse('$QRDOORBELL_API_URL/api/v1/doorbells/remove'), body: {'doorbellId': doorbell.doorbellId});
    if (resp.statusCode != 200) {
      logger.warning('Failed to accept Doorbell Invite - API returned an error: ${resp.body}');
      throw AssertionError('Failed to remove Doorbell - API returned an error: ${resp.body}');
    }

    await reloadData(true);
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

    var resp = await HttpUtils.securePost(Uri.parse('$QRDOORBELL_INVITE_API_URL/invite/accept/$inviteId'));
    if (resp.statusCode != 200) {
      logger.warning('Failed to accept Doorbell Invite - API returned an error: ${resp.body}');
      throw AssertionError('Failed to accept Doorbell Invite - API returned an error: ${resp.body}');
    }

    await reloadData(true);
    return resp.body; // doorbellId
  }

  @override
  Future<void> saveInvite(Invite invite) async {
    await db.ref('invites/${invite.id}').set(invite.toMap());
  }

  void _clearData() {
    _doorbellUsersRepository.clear();
    _eventsRepository.clear();
    _doorbellUsersRepository.clear();
    _currentUser = null;
  }
}
