import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_database/firebase_database.dart';
import 'model/doorbell.dart';
import 'model/doorbell_event.dart';

export 'package:uuid/uuid.dart';
export 'model/doorbell.dart';
export 'model/doorbell_event.dart';

final storeInstance = DataStore.createMock();

abstract class DataStore {
  List<Doorbell> get allDoorbells;
  List<DoorbellEvent> get allEvents;

  DataStore._();

  factory DataStore.createMock() => MockedDataStore._();

  List<DoorbellEvent> getDoorbellEvents(String doorbellId) => allEvents.where((element) => element.doorbellId == doorbellId).toList();
  Doorbell? getDoorbellById(String doorbellId) => allDoorbells.firstWhereOrNull((element) => element.doorbellId == doorbellId);
}

class MockedDataStore extends DataStore {
  MockedDataStore._() : super._();

  @override
  List<Doorbell> get allDoorbells => [
        Doorbell(doorbellId: '1', name: 'Doorbell 1'),
        Doorbell(doorbellId: '2', name: 'Doorbell 2'),
        Doorbell(doorbellId: '3', name: 'Doorbell My'),
        Doorbell(doorbellId: '4', name: 'Doorbell Yours'),
        Doorbell(doorbellId: '5', name: 'Doorbell Shared'),
      ];

  @override
  List<DoorbellEvent> get allEvents => ([
        DoorbellEvent.doorbell('3', DateTime.parse("2023-02-27 13:27:00")),
        DoorbellEvent.answeredCall('3', DateTime.parse("2023-02-27 13:28:00")),
        DoorbellEvent.doorbell('1', DateTime.parse("2023-02-13 23:55:00")),
        DoorbellEvent.doorbell('1', DateTime.parse("2023-01-11 09:09:00")),
        DoorbellEvent.doorbell('1', DateTime.parse("2023-01-11 09:09:15")),
        DoorbellEvent.doorbell('3', DateTime.parse("2023-03-04 16:23:03")),
        DoorbellEvent.textMessage('3', DateTime.parse("2022-09-22 23:10:03"), 'This is delivery, please call me back at +380991234567'),
        DoorbellEvent.doorbell('1', DateTime.parse("2023-01-11 09:09:30")),
        DoorbellEvent.textMessage('1', DateTime.parse("2023-01-11 09:10:00"), 'Hi there, is anybody home?'),
        DoorbellEvent.missedCall('3', DateTime.parse("2023-03-02 10:11:33")),
        DoorbellEvent.voiceMessage('3', DateTime.parse("2023-03-02 10:13:03")),
        DoorbellEvent.voiceMessage('3', DateTime.parse("2023-03-04 18:51:03")),
        DoorbellEvent.voiceMessage('9', DateTime.parse("2023-03-04 10:13:03")),
      ]..sortBy((element) => element.dateTime))
          .reversed
          .toList();

  void addDoorbell(Doorbell doorbell) {
    allDoorbells.add(doorbell);
  }
}

class FirebaseDataStore extends DataStore {
  final FirebaseDatabase db;
  late final List<Doorbell> doorbells = List.empty();
  late final List<DoorbellEvent> events = List.empty();

  FirebaseDataStore._({required this.db}) : super._() {
    db.ref('doorbells').onChildAdded.listen((e) {
      doorbells.addAll(e.snapshot.children.map<Doorbell>((x) => Doorbell.fromSnapshot(x)));
    });
    // ..onChildRemoved.listen((e) { doorbells.removeWhere((x) => e.snapshot.children.any((i) => x.doorbellId == i.) });

    db.ref('events').onChildAdded.listen((e) {
      events.addAll(e.snapshot.children.map<DoorbellEvent>((x) => DoorbellEvent.fromSnapshot(x)));
    });
  }

  @override
  List<Doorbell> get allDoorbells => doorbells;
  List<DoorbellEvent> get allEvents => events;
}
