import 'dart:math';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

extension AvatarExtensions on UserAccount? {
  String getShortName() => UserAccount.getShortName(this);
  Color getAvatarColor() => UserAccount.getColorFromShortName(UserAccount.getShortName(this));
}

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

  Map toMap() {
    var result = {
      'id': userId,
      'created': created.millisecondsSinceEpoch,
      // 'idps': idps.map((e) => {'key': e.provider, 'value': e.toMap()}).toList(growable: false),
      'enableVideoCalls': enableVideoCalls,
      'enableAudioCalls': enableAudioCalls,
      'enableVideoPreview': enableVideoPreview,
      'enableVoiceMail': enableVoiceMail,
      'enableTextMail': enableTextMail,
      'enablePushNotifications': enablePushNotifications,
    };

    if (firstName != null) result['firstName'] = firstName!;
    if (lastName != null) result['lastName'] = lastName!;
    if (displayName != null) result['displayName'] = displayName!;
    if (email != null) result['email'] = email!;
    if (doorbells.isNotEmpty) result['doorbells'] = doorbells.map((e) => {'key': e, 'value': true}).toList(growable: false);

    return result;
  }

  static UserAccount fromSnapshot(DataSnapshot snapshot) => UserAccount._(snapshot);

  static UserAccount fromUser(User user) => UserAccount(userId: user.uid)
    ..email = user.email
    ..displayName = user.displayName
    ..firstName = user.displayName
    ..lastName = '';

  static String getShortName(UserAccount? user) {
    if (user == null) return "--";

    if (isNotEmpty(user.firstName) && isNotEmpty(user.lastName)) return '${user.firstName![0]}${user.lastName![0]}'.toUpperCase();
    return getShortNameFromDisplayName(user.displayName);
  }

  static String getShortNameFromDisplayName(String? displayName) {
    if (isNotEmpty(displayName)) {
      var parts = displayName!.split(' ');
      if (parts.length > 1)
        return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      else if (displayName.length > 1)
        return displayName.substring(0, 2).toUpperCase();
      else
        return displayName.toUpperCase();
    }

    return "--";
  }

  static Color getColorFromShortName(String? displayName) => _UserAvatarColorScheme.getColorFromDisplayName(displayName).backgroundColor;
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

class _UserAvatarColorScheme {
  final Color backgroundColor;
  final Color textColor;

  // ignore: unused_element
  _UserAvatarColorScheme(this.backgroundColor, [this.textColor = Colors.white]);

  static _UserAvatarColorScheme getColorFromDisplayName(String? displayName) {
    if (displayName == null || displayName.isEmpty || displayName.startsWith('-')) return _userAvatarColorSchemes[0];

    var h = hashIgnoreAsciiCase(displayName);
    var i = ((h * pi).round() % (_userAvatarColorSchemes.length - 1)) + 1;

    return _userAvatarColorSchemes[i];
  }

  static final _userAvatarColorSchemes = <_UserAvatarColorScheme>[
    _UserAvatarColorScheme(Colors.blueGrey.shade100),
    _UserAvatarColorScheme(Colors.pinkAccent.shade200),
    _UserAvatarColorScheme(Colors.amberAccent),
    _UserAvatarColorScheme(Colors.blueAccent),
    _UserAvatarColorScheme(Colors.purpleAccent),
    _UserAvatarColorScheme(Colors.redAccent.shade400),
    _UserAvatarColorScheme(Colors.teal.shade400),
    _UserAvatarColorScheme(Colors.deepPurpleAccent),
    _UserAvatarColorScheme(Colors.greenAccent.shade400),
    _UserAvatarColorScheme(Colors.deepOrange),
    _UserAvatarColorScheme(Colors.lime),
  ];
}
