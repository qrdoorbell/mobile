import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class Doorbell {
  final String doorbellId;
  String name;
  DoorbellSettings settings;

  Doorbell({
    required this.doorbellId,
    required this.name,
  }) : settings = DoorbellSettings();

  Doorbell._({
    required this.doorbellId,
    required this.name,
    required this.settings,
  });

  factory Doorbell.fromSnapshot(DataSnapshot snapshot) {
    final s = snapshot.value as Map<String, dynamic>;

    return Doorbell._(doorbellId: s['doorbellId'], name: s['name'], settings: DoorbellSettings.fromSnapshot(snapshot.child('settings')));
  }
}

class DoorbellSettings {
  bool enableVideoCalls = true;
  bool enableAudioCalls = true;
  bool enableVideoPreview = true;
  bool enableVoiceMail = false;
  bool enableTextMail = false;
  bool enablePushNotifications = true;
  bool automaticStateSettingsEnabled = false;
  TimeRangeForStateSettings? automaticStateSettings;

  DoorbellSettings();

  DoorbellSettings._({
    this.enableVideoCalls = true,
    this.enableAudioCalls = true,
    this.enableVideoPreview = true,
    this.enableVoiceMail = false,
    this.enableTextMail = false,
    this.enablePushNotifications = true,
    this.automaticStateSettingsEnabled = false,
    this.automaticStateSettings,
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
      automaticStateSettingsEnabled: s['automaticStateSettingsEnabled'],
      automaticStateSettings:
          s['automaticStateSettings'] != null ? TimeRangeForStateSettings.fromSnapshot(snapshot.child('automaticStateSettings')) : null,
    );
  }
}

class TimeRangeForStateSettings {
  DateTime startTime;
  DateTime endTime;
  bool targetState;

  TimeRangeForStateSettings({
    required this.startTime,
    required this.endTime,
    required this.targetState,
  });

  factory TimeRangeForStateSettings.fromSnapshot(DataSnapshot snapshot) {
    final s = snapshot.value as Map<String, dynamic>;

    return TimeRangeForStateSettings(
      startTime: s['startTime'],
      endTime: s['endTime'],
      targetState: s['targetState'],
    );
  }
}
