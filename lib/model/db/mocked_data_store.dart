import 'package:collection/collection.dart';
import 'package:qrdoorbell_mobile/model/user_account.dart';

import '../../data.dart';

class MockedDataStore extends DataStore {
  MockedDataStore();

  @override
  UserAccount? get currentUser =>
      UserAccount(userId: 'user1_id', displayName: 'Test User', firstName: 'Test', lastName: 'User', email: 't@us.er');

  @override
  List<DoorbellSettings> get allDoorbellSettings => [];

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
    allDoorbells.add(doorbell);
  }

  @override
  Future<void> setUid(String? uid) {
    return Future.value(null);
  }

  @override
  Future<void> reloadData() {
    return Future.value(null);
  }
}
