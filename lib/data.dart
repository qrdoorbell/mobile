import 'model/doorbell.dart';

export 'model/doorbell.dart';

final storeInstance = DataStore();

class DataStore {
  final List<Doorbell> allDoorbells = [];

  void addDoorbell(Doorbell doorbell) {
    allDoorbells.add(doorbell);
  }
}
