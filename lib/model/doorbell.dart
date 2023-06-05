import 'package:firebase_database/firebase_database.dart';
import '../data.dart';

class Doorbell implements Comparable<Doorbell> {
  late final String doorbellId;
  String name = '';
  bool enabled = true;
  DoorbellEvent? lastEvent;
  late DoorbellSettings settings;
  List<DoorbellSticker> stickers = <DoorbellSticker>[];

  Doorbell(this.doorbellId, [this.name = '', DoorbellSettings? settings]) : settings = settings ?? DoorbellSettings();

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

    if (s['stickers']?.entries != null) {
      stickers.addAll(List.from(s['stickers'].entries).map((v) {
        return DoorbellSticker.fromMapAndId(v.key, v.value);
      }).toList());
    }
  }

  static Doorbell fromMap(Map s) => Doorbell._(s);
  static Doorbell fromSnapshot(DataSnapshot snapshot) => Doorbell._(Map.of(snapshot.value as dynamic));

  Map toMap() => {
        'id': doorbellId,
        'enabled': enabled,
        'name': name,
        'lastEvent': lastEvent?.toMap(),
        'settings': settings.toMap(),
        'stickers': stickers.map((e) => e.toMap()).toList(growable: false),
      };

  @override
  String toString() => 'Doorbell(doorbellId: $doorbellId, name: $name, enaabled: $enabled, lastEvent: $lastEvent)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Doorbell && other.doorbellId == doorbellId && other.name == name;
  }

  @override
  int get hashCode => doorbellId.hashCode ^ name.hashCode;

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

  Map<String, dynamic> toMap() => {
        'enableVideoCalls': enableVideoCalls,
        'enableAudioCalls': enableAudioCalls,
        'enableVideoPreview': enableVideoPreview,
        'enableVoiceMail': enableVoiceMail,
        'enableTextMail': enableTextMail,
        'enablePushNotifications': enablePushNotifications,
        'automaticStateSettings': automaticStateSettings?.toMap(),
      };
}

class DoorbellUser {
  String doorbellId;
  String userId;
  String role;
  String? userDisplayName;
  String? userShortName;

  DoorbellUser({
    required this.doorbellId,
    required this.userId,
    required this.role,
    this.userDisplayName,
    this.userShortName,
  });
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

  factory TimeRangeForStateSettings.createDefault() {
    return TimeRangeForStateSettings(startTime: DateTime(2023, 1, 1, 23, 0), endTime: DateTime(2023, 1, 2, 6, 0), targetState: false);
  }

  Map toMap() => {
        'start': startTime.millisecondsSinceEpoch,
        'end': endTime.millisecondsSinceEpoch,
        'targetEnabledState': targetState,
        'enabled': enabled,
      };
}
