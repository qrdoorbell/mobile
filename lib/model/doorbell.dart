import 'package:firebase_database/firebase_database.dart';
import 'package:qrdoorbell_mobile/data.dart';

class Doorbell {
  late final String doorbellId;
  late String name;
  bool enabled = true;
  DoorbellEvent? lastEvent;

  Doorbell({
    required this.doorbellId,
    required this.name,
  });

  Doorbell._(DataSnapshot snapshot) {
    final s = Map.of(snapshot.value as dynamic);

    doorbellId = snapshot.key!;
    name = s['name'];
    enabled = s['enabled'];
    lastEvent = DoorbellEvent.fromMap(doorbellId, s['lastEvent']);
  }

  static Doorbell fromSnapshot(DataSnapshot snapshot) => Doorbell._(snapshot);
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
