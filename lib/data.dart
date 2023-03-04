import 'model/doorbell.dart';

export 'model/doorbell.dart';

final storeInstance = DataStore();

class DataStore {
  final List<Doorbell> allDoorbells = [
    Doorbell(id: '1', name: 'Doorbell 1'),
    Doorbell(id: '2', name: 'Doorbell 2'),
    Doorbell(id: '3', name: 'Doorbell My'),
    Doorbell(id: '4', name: 'Doorbell Yours'),
    Doorbell(id: '5', name: 'Doorbell Shared'),
  ];

  void addDoorbell(Doorbell doorbell) {
    allDoorbells.add(doorbell);
  }
}
