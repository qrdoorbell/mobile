import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/model/helpers/id_provider.dart';
import 'model/doorbell.dart';
import 'model/doorbell_event.dart';

export 'model/doorbell.dart';
export 'model/doorbell_event.dart';

abstract class DataStore extends IdProvider {
  List<Doorbell> get allDoorbells;
  List<DoorbellEvent> get allEvents;
  List<DoorbellSettings> get allDoorbellSettings;

  List<DoorbellEvent> getDoorbellEvents(String doorbellId) => allEvents.where((element) => element.doorbellId == doorbellId).toList();
  Doorbell? getDoorbellById(String doorbellId) => allDoorbells.firstWhereOrNull((element) => element.doorbellId == doorbellId);

  Future<void> setUid(String? uid);
  Future<void> reloadData();

  static DataStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DataStoreStateScope>()!.notifier!.dataStore;
}

class DataStoreState extends ChangeNotifier {
  String? _uid;
  final DataStore dataStore;

  DataStoreState({
    required this.dataStore,
  }) {
    _uid = FirebaseAuth.instance.currentUser?.uid;
    FirebaseAuth.instance.userChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user?.uid == null) {
      _uid = null;
      await dataStore.setUid(null);
      notifyListeners();
    } else if (_uid != user?.uid) {
      _uid = user?.uid;
      await dataStore.setUid(_uid);
      notifyListeners();
    } else {
      await dataStore.setUid(_uid);
      // await dataStore.reloadData();
      notifyListeners();
    }
  }
}

/// Provides the current [DataStoreState] to descendant widgets in the tree.
class DataStoreStateScope extends InheritedNotifier<DataStoreState> {
  const DataStoreStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static DataStoreState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DataStoreStateScope>()!.notifier!;
}
