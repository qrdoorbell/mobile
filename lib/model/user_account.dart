import 'package:firebase_auth/firebase_auth.dart';
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
  bool enableVideoCalls = true;
  bool enableAudioCalls = true;
  bool enableVideoPreview = true;
  bool enableVoiceMail = true;
  bool enableTextMail = true;
  bool enablePushNotifications = true;

  UserAccount({required this.userId, this.firstName, this.lastName, this.displayName, this.email}) {
    created = DateTime.now();
    idps = <UserAccountIdp>[];
    doorbells = <String>[];
  }

  UserAccount._(DataSnapshot snapshot) {
    final s = Map.of(snapshot.value as dynamic);

    userId = snapshot.key ?? s['id'];
    firstName = s['firstName'];
    lastName = s['lastName'];
    displayName = s['displayName'];
    email = s['email'];
    created = DateTime.fromMillisecondsSinceEpoch(s['created']);
    enableVideoCalls = s['enableVideoCalls'] ?? true;
    enableAudioCalls = s['enableAudioCalls'] ?? true;
    enableVideoPreview = s['enableVideoPreview'] ?? true;
    enableVoiceMail = s['enableVoiceMail'] ?? true;
    enableTextMail = s['enableTextMail'] ?? true;
    enablePushNotifications = s['enablePushNotifications'] ?? true;

    if (s['idps']?.entries != null) {
      idps = List.from(s['idps'].entries)
          .map((x) => UserAccountIdp(provider: x.value['provider'] ?? x.key, providerUserId: x.value['id']))
          .toList();
    } else
      idps = [];

    if (s['doorbells']?.entries != null) {
      doorbells = List.from(s['doorbells'].entries).map((x) => x.key.toString()).toList();
    } else
      doorbells = [];
  }

  Map toMap() => {
        'id': userId,
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'email': email,
        'created': created.millisecondsSinceEpoch,
        'idps': idps.map((e) => {'key': e.provider, 'value': e.toMap()}).toList(growable: false),
        'doorbells': doorbells.map((e) => {'key': e, 'value': true}).toList(growable: false),
        'enableVideoCalls': enableVideoCalls,
        'enableAudioCalls': enableAudioCalls,
        'enableVideoPreview': enableVideoPreview,
        'enableVoiceMail': enableVoiceMail,
        'enableTextMail': enableTextMail,
        'enablePushNotifications': enablePushNotifications,
      };

  static UserAccount fromSnapshot(DataSnapshot snapshot) => UserAccount._(snapshot);

  static UserAccount fromUser(User user) => UserAccount(userId: user.uid)
    ..email = user.email
    ..displayName = user.displayName
    ..firstName = user.displayName
    ..lastName = '';
}

class UserAccountIdp {
  final String provider;
  final String providerUserId;

  UserAccountIdp({required this.provider, required this.providerUserId});

  Map toMap() => {
        'provider': provider,
        'id': providerUserId,
      };
}
