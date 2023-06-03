import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';

import '../../data.dart';

abstract class FirebaseRepository<T> {
  final logger = Logger("FirebaseRepository<$T>");

  late StreamController<List<T>> _controller;
  final _subs = <StreamSubscription<DatabaseEvent>>[];
  final _cache = <T>[];

  FirebaseRepository() {
    _setupStream();
  }

  void _setupStream() {
    _controller = StreamController<List<T>>.broadcast();
    _controller.onListen = () {
      _controller.sink.add(_cache);
    };
  }

  void _refSubscribe(StreamSubscription<DatabaseEvent> sub) => _subs.add(sub);
  void _refOnMultipleValues(DatabaseEvent event) {
    if (logger.isLoggable(Level.FINEST))
      logger.finest("FirebaseRepository<$T>._refOnMultipleValues: event=${event.snapshot.value.toString()}");
    _addValues(event.snapshot.children.map((x) => convertFromMap(x.value as Map)).whereNot((x) => x == null).map((x) => x!));
  }

  void _refOnSingleValue(DatabaseEvent event) {
    if (logger.isLoggable(Level.FINEST))
      logger.finest("FirebaseRepository<$T>._refOnSingleValue: event=${event.snapshot.value.toString()}");
    convertFromSnapshot(event.snapshot);
  }

  void _refOnError(obj, stackTrace) {
    logger.warning('Error occured!', obj, stackTrace);
  }

  T? convertFromSnapshot(DataSnapshot snapshot) {
    if (snapshot.value != null && snapshot.value is Map) {
      final val = convertFromMap(snapshot.value as Map);
      if (val != null) _addValues([val]);

      return val;
    }

    return null;
  }

  void _addValues(Iterable<T> data) {
    _cache.removeWhere((x) => data.contains(x));
    _cache.addAll(data);
    _controller.sink.add(_cache);
  }

  List<T> get snapshot => _cache;

  Stream<List<T>> get stream =>
      _controller.stream.transform(StreamTransformer.fromHandlers(handleData: (data, sink) => sink.add(_cache..sort())));

  Future<void> dispose() async {
    logger.fine("FirebaseRepository<$T>.dispose");
    for (var sub in _subs) await sub.cancel();
    _controller.close();
    _cache.clear();

    _setupStream();
  }

  T? convertFromMap(Map m);
}

class DoorbellEventsRepository extends FirebaseRepository<DoorbellEvent> {
  final FirebaseDatabase db;

  DoorbellEventsRepository(this.db);

  // Future<List<DoorbellEvent>> getByDoorbellId(String doorbellId) async {
  //   return convertFromSnapshot(await db.ref('doorbells/$doorbellId').get());
  // }

  void subscribeTo(String doorbellId) {
    if (logger.isLoggable(Level.FINEST)) logger.finest("DoorbellEventsRepository.subscribeTo: doorbellId=$doorbellId");
    // _refSubscribe(db.ref('doorbell-events/$doorbellId').onValue.listen(_refOnMultipleValues, onError: _refOnError, cancelOnError: false));
    _refSubscribe(db.ref('doorbell-events/$doorbellId').onChildAdded.listen(_refOnSingleValue, onError: _refOnError, cancelOnError: false));
  }

  void addValues(Iterable<DoorbellEvent> data) => _addValues(data);

  @override
  DoorbellEvent? convertFromMap(Map m) => DoorbellEvent.fromMap(m);
}

class DoorbellsRepository extends FirebaseRepository<Doorbell> {
  final FirebaseDatabase db;

  DoorbellsRepository(this.db);

  Future<Doorbell?> getById(String doorbellId) async {
    return convertFromSnapshot(await db.ref('doorbells/$doorbellId').get());
  }

  void subscribeTo(String doorbellId) {
    if (logger.isLoggable(Level.FINEST)) logger.finest("DoorbellsRepository.subscribeTo: doorbellId=$doorbellId");

    var doorbellRef = db.ref('doorbells/$doorbellId')..keepSynced(true);
    _refSubscribe(doorbellRef.onValue.listen(_refOnSingleValue,
        onError: _refOnError,
        cancelOnError: false,
        onDone: () => {
              if (logger.isLoggable(Level.FINEST))
                logger.finest('DoorbellsRepository._subscription.onDone: subscription=doorbels/$doorbellId')
            }));

    _refSubscribe(doorbellRef.onChildChanged.listen(_onDoorbellUpdated, onError: _refOnError, cancelOnError: false));
    _refSubscribe(doorbellRef.onChildRemoved.listen(_onDoorbellRemoved, onError: _refOnError, cancelOnError: false));

    var userDoorbellsRef = db.ref('users/${FirebaseAuth.instance.currentUser!.uid}/doorbells')..keepSynced(true);
    _refSubscribe(userDoorbellsRef.onChildAdded.listen(
      _onDoorbellAdded,
      onError: _refOnError,
      cancelOnError: false,
    ));
    // _refSubscribe(db.ref('doorbells').onChildAdded.listen(_refOnSingleValue, onError: _refOnError, cancelOnError: false));
  }

  void _onDoorbellAdded(DatabaseEvent event) {
    if (event.snapshot.exists && event.snapshot.key != null && event.snapshot.value == true) {
      if (!_cache.any((x) => x.doorbellId == event.snapshot.key)) {
        // logger.fine('DoorbellsRepository._onDoorbellAdded: cache miss -- start retrieve doorbell, doorbellId=${event.snapshot.key.toString()}');
        // logger.fine(_cache);
        // db.ref('doorbells/${event.snapshot.key}').get();
      }
    }
  }

  void _onDoorbellUpdated(DatabaseEvent event) {
    logger.fine("DoorbellsRepository._onDoorbellUpdated: event=${event.snapshot.value.toString()}");

    if (event.snapshot.key?.length == 10) {
      var newValue = convertFromMap(event.snapshot.value as Map);
      if (newValue != null) {
        _cache.removeWhere((x) => x.doorbellId == newValue.doorbellId);
        _cache.add(newValue);

        _controller.sink.add(_cache);
      }
    }
  }

  void _onDoorbellRemoved(DatabaseEvent event) {
    logger.fine("DoorbellsRepository._onDoorbellRemoved: event=${event.snapshot.ref.key.toString()}");

    _cache.removeWhere((x) => x.doorbellId == event.snapshot.ref.key);
    _controller.sink.add(_cache);
  }

  Future<Doorbell> create(Doorbell doorbell) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // TODO: move this code to API
    await db.ref('users/$uid/doorbells/${doorbell.doorbellId}').set(true);
    await db.ref('doorbell-users/${doorbell.doorbellId}/$uid').set({'role': 'owner', 'created': DateTime.now().millisecondsSinceEpoch});
    await db.ref('doorbells/${doorbell.doorbellId}').set(doorbell.toMap());

    var d = Doorbell.fromSnapshot(await db.ref('doorbells/${doorbell.doorbellId}').get());
    if (!_cache.contains(d)) {
      _cache.add(d);
      _controller.sink.add(_cache);
    }

    return d;
  }

  Future<void> update(Doorbell doorbell) async {
    await db.ref('doorbells/${doorbell.doorbellId}').set(doorbell.toMap());
  }

  Future<void> remove(Doorbell doorbell) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // TODO: move this code to API
    var role = (await db.ref('doorbell-users/${doorbell.doorbellId}/$uid/role').get()).value as String?;
    if (role == 'participant') {
      await db.ref('users/$uid/doorbells/${doorbell.doorbellId}').remove();
      await db.ref('doorbell-users/${doorbell.doorbellId}/$uid/role').remove();
    } else if (role == 'owner') {
      var doorbellUsers = (await db.ref('doorbell-users/${doorbell.doorbellId}').get()).children.map((x) => x.value);
      for (var u in doorbellUsers) {
        await db.ref('users/$u/doorbells/${doorbell.doorbellId}').remove();
      }
      await db.ref('doorbell-users/${doorbell.doorbellId}').remove();
      await db.ref('users/$uid/doorbells/${doorbell.doorbellId}').remove();
      await db.ref('doorbells/${doorbell.doorbellId}').remove();
    }
  }

  @override
  Doorbell? convertFromMap(Map m) => Doorbell.fromMap(m);
}
