import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data.dart';

class FirebaseDataStore extends DataStore {
  String? _uid;
  UserAccount? _currentUser;
  List<Doorbell> _doorbells = <Doorbell>[];
  List<DoorbellEvent> _events = <DoorbellEvent>[];
  final FirebaseDatabase db;

  FirebaseDataStore({required this.db}) : super();

  @override
  Future<void> setUid(String? uid) async {
    _uid = uid;
    await reloadData();
  }

  @override
  Future<void> reloadData() async {
    _doorbells.clear();
    _events.clear();
    _currentUser = null;

    if (_uid == null) return;

    try {
      print("Reloading data for user: userId='$_uid'");
      _currentUser = UserAccount.fromSnapshot(await db.ref('users/$_uid').get());
    } catch (e) {
      print(e);
    }

    for (var doorbellId in _currentUser!.doorbells) {
      try {
        print("Retrieving doorbell info: path='doorbells/$doorbellId'");
        _doorbells.add(Doorbell.fromSnapshot(await db.ref('doorbells/$doorbellId').get()));

        print("Retrieving doorbell events: path='doorbell-events/$doorbellId'");
        db.ref('doorbell-events/$doorbellId').onValue.listen((x) {
          for (var s in List.from(x.snapshot.children)) {
            _events.add(DoorbellEvent.fromMapAndId(doorbellId, s.key!, Map.of(s.value as dynamic)));
          }
        });
      } catch (e) {
        print(e);
      }
    }

    _doorbells.sortBy((_) => _.name);
    _events.sortBy((_) => _.dateTime);
  }

  @override
  List<Doorbell> get allDoorbells => _doorbells;

  @override
  List<DoorbellEvent> get allEvents => _events;

  @override
  UserAccount? get currentUser => _currentUser;
}
