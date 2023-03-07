import 'package:firebase_database/firebase_database.dart';
import 'package:qrdoorbell_mobile/model/user_account.dart';

import '../../data.dart';

class FirebaseDataStore extends DataStore {
  String? _uid;
  bool _isCacheClean = true;
  bool _isDataLoaded = false;
  List<Doorbell> _doorbells = <Doorbell>[];
  List<DoorbellEvent> _events = <DoorbellEvent>[];
  List<DoorbellSettings> _doorbellSettings = <DoorbellSettings>[];
  final FirebaseDatabase db;

  String? get uid => _uid;

  FirebaseDataStore({required this.db}) : super();

  @override
  Future<void> setUid(String? uid) async {
    if (!_isCacheClean) cacheClean();

    _uid = uid;
    await cacheReload();
  }

  @override
  Future<void> reloadData() async {
    if (!_isDataLoaded) {
      await cacheReload();
    }
  }

  Future<void> cacheReload() async {
    if (uid == null) return;
    _isCacheClean = false;

    print("Reloading data for user: userId='$uid'");
    var user = UserAccount.fromSnapshot(await db.ref('users/$uid').get());
    for (var doorbellId in user.doorbells) {
      try {
        print("Retrieving doorbell info: path='doorbells/$doorbellId'");
        _doorbells.add(Doorbell.fromSnapshot(await db.ref('doorbells/$doorbellId').get()));

        print("Retrieving doorbell events: path='doorbell-events/$doorbellId'");
        db.ref('doorbell-events/$doorbellId').onValue.listen((x) {
          for (var s in List.from(x.snapshot.children)) {
            _events.add(DoorbellEvent.fromMapAndId(doorbellId, s.key!, Map.of(s.value as dynamic)));
          }
        });

        print("Retrieving doorbell settings: path='doorbell-settings/$doorbellId/settings'");
        db.ref('doorbell-settings/$doorbellId/settings').onValue.listen((x) {
          var settings = DoorbellSettings.fromMapAndId(doorbellId, Map.of(x.snapshot.value as dynamic));
          _doorbellSettings.add(settings);
        });
      } catch (e) {
        print(e);
      }
    }

    _isDataLoaded = true;
  }

  void cacheClean() {
    if (_isCacheClean) return;

    _doorbellSettings.clear();
    _doorbells.clear();
    _events.clear();
  }

  @override
  List<Doorbell> get allDoorbells => _doorbells;

  @override
  List<DoorbellEvent> get allEvents => _events;

  @override
  List<DoorbellSettings> get allDoorbellSettings => _doorbellSettings;
}
