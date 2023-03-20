import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../data.dart';

abstract class FirebaseRepository<T> {
  var _controller = StreamController<List<T>>.broadcast();
  final _subs = <StreamSubscription<DatabaseEvent>>[];
  final _cache = <T>[];

  FirebaseRepository();

  void _refSubscribe(StreamSubscription<DatabaseEvent> sub) => _subs.add(sub);
  void _refOnMultipleValues(DatabaseEvent event) => _addValues(event.snapshot.children.map((x) => convertFromMap(x.value as Map)));
  void _refOnSingleValue(DatabaseEvent event) => _addValues([convertFromMap(event.snapshot.value as Map)]);

  void _refOnError(obj, stackTrace) {
    print('Error occured: $obj\n---\nAt: $stackTrace');
  }

  void _addValues(Iterable<T> data) {
    _cache.addAll(data.where((x) => !_cache.contains(x)));
    _controller.sink.add(_cache);
  }

  List<T> get snapshot => _cache;

  Stream<List<T>> get stream => _controller.stream.transform(StreamTransformer.fromHandlers(handleData: (data, sink) {
        _cache
          ..addAll(data.where((x) => !_cache.contains(x)))
          ..sort();

        sink.add(_cache);
      }));

  Future<void> dispose() async {
    for (var sub in _subs) await sub.cancel();
    _controller.close();
    _cache.clear();

    _controller = StreamController<List<T>>.broadcast();
  }

  T convertFromMap(Map m);
}

class DoorbellEventsRepository extends FirebaseRepository<DoorbellEvent> {
  final FirebaseDatabase db;

  DoorbellEventsRepository(this.db);

  void subscribeTo(String doorbellId) {
    _refSubscribe(db.ref('doorbell-events/$doorbellId').onValue.listen(_refOnMultipleValues, onError: _refOnError, cancelOnError: false));
    _refSubscribe(db.ref('doorbell-events/$doorbellId').onChildAdded.listen(_refOnSingleValue, onError: _refOnError, cancelOnError: false));
  }

  void addValues(Iterable<DoorbellEvent> data) => _addValues(data);

  @override
  DoorbellEvent convertFromMap(Map m) => DoorbellEvent.fromMap(m);
}

class DoorbellsRepository extends FirebaseRepository<Doorbell> {
  final FirebaseDatabase db;

  DoorbellsRepository(this.db);

  void subscribeTo(String doorbellId) {
    _refSubscribe(db.ref('doorbells/$doorbellId').onValue.listen(_refOnSingleValue, onError: _refOnError, cancelOnError: false));
    // _refSubscribe(db.ref('doorbells').onChildAdded.listen(_refOnSingleValue, onError: _refOnError, cancelOnError: false));
  }

  Future<Doorbell> create(Doorbell doorbell) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    await db.ref('users/$uid/doorbells/${doorbell.doorbellId}').set(true);
    await db.ref('doorbell-users/${doorbell.doorbellId}/$uid').set({'role': 'owner', 'created': DateTime.now().millisecondsSinceEpoch});
    await db.ref('doorbells/${doorbell.doorbellId}').set(doorbell.toMap());

    return Doorbell.fromSnapshot(await db.ref('doorbells/${doorbell.doorbellId}').get());
  }

  Future<void> update(Doorbell doorbell) async {
    await db.ref('doorbells/${doorbell.doorbellId}').set(doorbell.toMap());
  }

  @override
  Doorbell convertFromMap(Map m) => Doorbell.fromMap(m);
}
