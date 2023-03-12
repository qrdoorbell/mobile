import 'package:collection/collection.dart';

import '../../data.dart';

class MockedDataStore extends DataStore {
  MockedDataStore();

  @override
  UserAccount? get currentUser =>
      UserAccount(userId: 'user1_id', displayName: 'Test User', firstName: 'Test', lastName: 'User', email: 't@us.er');

  @override
  List<Doorbell> get doorbells => [
        Doorbell('1', 'Doorbell 1'),
        Doorbell('2', 'Doorbell 2'),
        Doorbell('3', 'Doorbell My'),
        Doorbell('4', 'Doorbell Yours'),
        Doorbell('5', 'Doorbell Shared'),
      ];

  @override
  List<DoorbellEvent> get doorbellEvents => ([
        DoorbellEvent.doorbell('3', '1', DateTime.parse("2023-02-27 13:27:00")),
        DoorbellEvent.answeredCall('3', '1', DateTime.parse("2023-02-27 13:28:00")),
        DoorbellEvent.doorbell('1', '2', DateTime.parse("2023-02-13 23:55:00")),
        DoorbellEvent.doorbell('1', '3', DateTime.parse("2023-01-11 09:09:00")),
        DoorbellEvent.doorbell('1', '2', DateTime.parse("2023-01-11 09:09:15")),
        DoorbellEvent.doorbell('3', '1', DateTime.parse("2023-03-04 16:23:03")),
        DoorbellEvent.textMessage(
            '3', '1', DateTime.parse("2022-09-22 23:10:03"), 'This is delivery, please call me back at +380991234567'),
        DoorbellEvent.doorbell('1', '3', DateTime.parse("2023-01-11 09:09:30")),
        DoorbellEvent.textMessage('1', '3', DateTime.parse("2023-01-11 09:10:00"), 'Hi there, is anybody home?'),
        DoorbellEvent.missedCall('3', '1', DateTime.parse("2023-03-02 10:11:33")),
        DoorbellEvent.voiceMessage('3', '2', DateTime.parse("2023-03-02 10:13:03")),
        DoorbellEvent.voiceMessage('3', '2', DateTime.parse("2023-03-04 18:51:03")),
        DoorbellEvent.voiceMessage('9', '2', DateTime.parse("2023-03-04 10:13:03")),
      ]..sortBy((element) => element.dateTime))
          .reversed
          .toList();

  void addDoorbell(Doorbell doorbell) {
    doorbells.add(doorbell);
  }

  @override
  Future<void> setUid(String? uid) {
    return Future.value(null);
  }

  @override
  Future<void> reloadData() {
    return Future.value(null);
  }

  @override
  Stream<List<DoorbellEvent>> get doorbellEventsStream => Stream.value(doorbellEvents);

  @override
  void addDoorbellEvent(int eventType, String doorbellId, String stickerId) {}

  @override
  Future<void> dispose() {
    return Future.value(null);
  }

  @override
  Stream<List<Doorbell>> get doorbellsStream => Stream.value(doorbells);

  @override
  Future<Doorbell> createDoorbell() {
    // TODO: implement createDoorbell
    throw UnimplementedError();
  }

  @override
  Future<void> updateDoorbell(Doorbell doorbell) {
    // TODO: implement updateDoorbell
    throw UnimplementedError();
  }
}
