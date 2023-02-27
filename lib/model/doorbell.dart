import 'package:firebase_database/firebase_database.dart';

class Doorbell {
  String id;
  String name;
  DoorbellSettings settings;

  Doorbell({
    required this.id,
    required this.name,
  }) : settings = DoorbellSettings();

  Doorbell._({
    required this.id,
    required this.name,
    required this.settings,
  });

  factory Doorbell.fromSnapshot(DataSnapshot snapshot) {
    final s = snapshot.value as Map<String, dynamic>;

    return Doorbell._(id: s['id'], name: s['name'], settings: DoorbellSettings.fromSnapshot(snapshot.child('settings')));
  }
}

class DoorbellSettings {
  bool enableVideoCalls = true;
  bool enableAudioCalls = true;
  bool enableVideoPreview = true;
  bool enableVoiceMail = false;
  bool enableTextMail = false;
  bool enablePushNotifications = true;

  DoorbellSettings();

  DoorbellSettings._({
    this.enableVideoCalls = true,
    this.enableAudioCalls = true,
    this.enableVideoPreview = true,
    this.enableVoiceMail = false,
    this.enableTextMail = false,
    this.enablePushNotifications = true,
  });

  factory DoorbellSettings.fromSnapshot(DataSnapshot snapshot) {
    final s = snapshot.value as Map<String, dynamic>;

    return DoorbellSettings._(
      enableVideoCalls: s['enableVideoCalls'],
      enableAudioCalls: s['enableAudioCalls'],
      enableVideoPreview: s['enableVideoPreview'],
      enableVoiceMail: s['enableVoiceMail'],
      enableTextMail: s['enableTextMail'],
      enablePushNotifications: s['enablePushNotifications'],
    );
  }
}
