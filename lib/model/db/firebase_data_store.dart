import 'dart:async';

import '../../data.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDataStore extends DataStore {
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
    if (_uid != uid) await dispose();

    _uid = uid;
    await reloadData();
  }

  @override
  Future<void> reloadData() async {
    if (_uid == null) {
      return;
    }

    try {
      print("Reloading data for user: userId='$_uid'");
      _currentUser = UserAccount.fromSnapshot(await db.ref('users/$_uid').get());
    } catch (e) {
      print(e);
    }

    for (var doorbellId in _currentUser!.doorbells) {
      try {
        print("Subscribe to doorbell: path='doorbells/$doorbellId'");
        _doorbellsRepository.subscribeTo(doorbellId);
        _eventsRepository.subscribeTo(doorbellId);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  UserAccount? get currentUser => _currentUser;

  @override
  List<Doorbell> get doorbells => _doorbellsRepository._cache;

  @override
  Stream<List<Doorbell>> get doorbellsStream => _doorbellsRepository.stream;

  @override
  List<DoorbellEvent> get doorbellEvents => _eventsRepository._cache;

  @override
  Stream<List<DoorbellEvent>> get doorbellEventsStream => _eventsRepository.stream;

  @override
  void addDoorbellEvent(int eventType, String doorbellId, String stickerId) {
    _eventsRepository._addValues([DoorbellEvent.create(eventType, doorbellId, stickerId)]);
  }

  @override
  Future<void> dispose() async {
    _currentUser = null;
    await _doorbellsRepository.dispose();
    await _eventsRepository.dispose();
  }
}

abstract class FirebaseRepository<T> {
  final _controller = StreamController<List<T>>.broadcast();
  final _subs = <StreamSubscription<DatabaseEvent>>[];
  final _cache = <T>[];

  FirebaseRepository();

  void _refSubscribe(StreamSubscription<DatabaseEvent> sub) => _subs.add(sub);
  void _refOnValue(DatabaseEvent event) => _addValues(event.snapshot.children.map((x) => convertFromMap(x.value as Map)));
  void _refOnSingleValue(DatabaseEvent event) => _addValues([convertFromMap(event.snapshot.value as Map)]);
  void _refOnChildAdded(DatabaseEvent event) => _addValues([convertFromMap(event.snapshot.value as Map)]);

  void _refOnError(obj, stackTrace) {
    print('Error occured: $obj\n---\nAt: $stackTrace');
  }

  void _addValues(Iterable<T> data) {
    _cache.addAll(data.where((x) => !_cache.contains(x)));
    _controller.sink.add(_cache);
  }

  Stream<List<T>> get stream => _controller.stream.transform(StreamTransformer.fromHandlers(handleData: (data, sink) {
        _cache
          ..addAll(data.where((x) => !_cache.contains(x)))
          ..sort();

        sink.add(_cache);
      }));

  Future<void> dispose() async {
    for (var sub in _subs) await sub.cancel();
    _cache.clear();
  }

  T convertFromMap(Map m);
}

class DoorbellEventsRepository extends FirebaseRepository<DoorbellEvent> {
  final FirebaseDatabase db;

  DoorbellEventsRepository(this.db);

  void subscribeTo(String doorbellId) {
    _refSubscribe(db.ref('doorbell-events/$doorbellId').onValue.listen(_refOnValue, onError: _refOnError, cancelOnError: false));
    _refSubscribe(db.ref('doorbell-events/$doorbellId').onChildAdded.listen(_refOnChildAdded, onError: _refOnError, cancelOnError: false));
  }

  @override
  DoorbellEvent convertFromMap(Map m) => DoorbellEvent.fromMap(m);
}

class DoorbellsRepository extends FirebaseRepository<Doorbell> {
  final FirebaseDatabase db;

  DoorbellsRepository(this.db);

  void subscribeTo(String doorbellId) {
    _refSubscribe(db.ref('doorbells/$doorbellId').onValue.listen(_refOnSingleValue, onError: _refOnError, cancelOnError: false));
    // _refSubscribe(db.ref('doorbells').onChildAdded.listen(_refOnChildAdded, onError: _refOnError, cancelOnError: false));
  }

  @override
  Doorbell convertFromMap(Map m) => Doorbell.fromMap(m);
}
