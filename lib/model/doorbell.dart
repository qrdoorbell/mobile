import 'package:firebase_database/firebase_database.dart';
import 'package:qrdoorbell_mobile/data.dart';
import 'doorbell_sticker.dart';

class Doorbell implements Comparable<Doorbell> {
  late final String doorbellId;
  late String name;
  bool enabled = true;
  DoorbellEvent? lastEvent;
  late DoorbellSettings settings;
  List<DoorbellSticker> stickers = <DoorbellSticker>[];

  Doorbell({required this.doorbellId, required this.name, DoorbellSettings? settings}) {
    this.settings = settings ?? DoorbellSettings();
  }

  Doorbell._(Map s) {
    doorbellId = s['id'];
    name = s['name'];
    enabled = s['enabled'];

    if (s['lastEvent'] != null) {
      lastEvent = DoorbellEvent.fromMapAndDoorbellId(doorbellId, s['lastEvent']);
    }

    if (s['settings'] != null) {
      settings = DoorbellSettings.fromMap(s['settings'] as Map);
    } else {
      settings = DoorbellSettings();
    }

    if (s['stickers'].entries != null) {
      stickers.addAll(List.from(s['stickers'].entries).map((v) {
        return DoorbellSticker.fromMapAndId(v.key, v.value);
      }).toList());
    }
  }

  static Doorbell fromMap(Map s) => Doorbell._(s);
  static Doorbell fromSnapshot(DataSnapshot snapshot) => Doorbell._(Map.of(snapshot.value as dynamic));

  @override
  int compareTo(Doorbell other) {
    return other.name.compareTo(name);
  }
}

class DoorbellSettings {
  bool enableVideoCalls = true;
  bool enableAudioCalls = true;
  bool enableVideoPreview = true;
  bool enableVoiceMail = false;
  bool enableTextMail = false;
  bool enablePushNotifications = true;
  TimeRangeForStateSettings? automaticStateSettings;

  DoorbellSettings({
    this.enableVideoCalls = true,
    this.enableAudioCalls = true,
    this.enableVideoPreview = true,
    this.enableVoiceMail = false,
    this.enableTextMail = false,
    this.enablePushNotifications = true,
    this.automaticStateSettings,
  });

  factory DoorbellSettings.fromMap(Map s) {
    return DoorbellSettings(
      enableVideoCalls: s['enableVideoCalls'],
      enableAudioCalls: s['enableAudioCalls'],
      enableVideoPreview: s['enableVideoPreview'],
      enableVoiceMail: s['enableVoiceMail'],
      enableTextMail: s['enableTextMail'],
      enablePushNotifications: s['enablePushNotifications'],
      automaticStateSettings: s['automaticStateSettings'] != null ? TimeRangeForStateSettings.fromMap(s['automaticStateSettings']) : null,
    );
  }
}

class TimeRangeForStateSettings {
  DateTime startTime;
  DateTime endTime;
  bool targetState;
  bool enabled = true;

  TimeRangeForStateSettings({
    required this.startTime,
    required this.endTime,
    required this.targetState,
    this.enabled = true,
  });

  factory TimeRangeForStateSettings.fromMap(Map s) {
    return TimeRangeForStateSettings(
      startTime: DateTime.fromMillisecondsSinceEpoch(s['start']),
      endTime: DateTime.fromMillisecondsSinceEpoch(s['end']),
      targetState: s['targetEnabledState'],
      enabled: s['enabled'],
    );
  }
}
