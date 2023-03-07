import 'package:firebase_database/firebase_database.dart';

class UserAccount {
  late final String userId;
  String? firstName;
  String? lastName;
  String? displayName;
  String? email;
  late DateTime created;
  late final List<UserAccountIdp> idps;
  late final List<String> doorbells;

  UserAccount({required this.userId, this.firstName, this.lastName, this.displayName, this.email}) {
    created = DateTime.now();
    idps = <UserAccountIdp>[];
    doorbells = <String>[];
  }

  UserAccount._(DataSnapshot snapshot) {
    final s = Map.of(snapshot.value as dynamic);

    userId = snapshot.key!;
    firstName = s['firstName'];
    lastName = s['lastName'];
    displayName = s['displayName'];
    email = s['email'];
    created = DateTime.fromMillisecondsSinceEpoch(s['created']);

    if (s['idps']?.entries != null) {
      idps = List.from(s['idps'].entries).map((x) => UserAccountIdp(provider: x.key, providerUserId: x.value['id'])).toList();
    }

    if (s['doorbells']?.entries != null) {
      doorbells = List.from(s['doorbells'].entries).map((x) => x.key.toString()).toList();
    }
  }

  static UserAccount fromSnapshot(DataSnapshot snapshot) => UserAccount._(snapshot);
}

class UserAccountIdp {
  final String provider;
  final String providerUserId;

  UserAccountIdp({required this.provider, required this.providerUserId});
}
