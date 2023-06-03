import 'package:nanoid/nanoid.dart';

class IdProvider {
  String getUniqueId() => nanoid(10);
}
