import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'package:qrdoorbell_mobile/data.dart';

class Doorbell {
  late final String doorbellId;
  late String name;
  bool enabled = true;
  DoorbellEvent? lastEvent;
  late DoorbellSettings settings;
  List<DoorbellSticker> stickers = <DoorbellSticker>[];

  Doorbell({required this.doorbellId, required this.name, DoorbellSettings? settings}) {
    this.settings = settings ?? DoorbellSettings();
  }

  Doorbell._(DataSnapshot snapshot) {
    final s = Map.of(snapshot.value as dynamic);

    doorbellId = snapshot.key!;
    name = s['name'];
    enabled = s['enabled'];

    if (s['lastEvent'] != null) {
      lastEvent = DoorbellEvent.fromMap(doorbellId, s['lastEvent']);
    }

    if (s['settings'] != null) {
      settings = DoorbellSettings.fromMap(s['settings'] as Map);
    } else {
      settings = DoorbellSettings();
    }

    if (s['stickers'].entries != null) {
      stickers.addAll(List.from(s['stickers'].entries).map((v) => DoorbellSticker.fromMap(v.value)).toList());
    }
  }

  static Doorbell fromSnapshot(DataSnapshot snapshot) => Doorbell._(snapshot);
}

class DoorbellSticker {
  final String stickerId;
  final String stickerTemplateId;
  final DateTime created;
  Map<String, dynamic> params;
  DoorbellSticker({
    required this.stickerId,
    required this.stickerTemplateId,
    required this.created,
    required this.params,
  });

  DoorbellSticker copyWith({
    String? stickerId,
    String? stickerTemplateId,
    DateTime? created,
    Map<String, dynamic>? params,
  }) {
    return DoorbellSticker(
      stickerId: stickerId ?? this.stickerId,
      stickerTemplateId: stickerTemplateId ?? this.stickerTemplateId,
      created: created ?? this.created,
      params: params ?? this.params,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': stickerId,
      'template': stickerTemplateId,
      'created': created.millisecondsSinceEpoch,
      'params': params,
    };
  }

  factory DoorbellSticker.fromMap(Map map) {
    return DoorbellSticker(
      stickerId: map['id'] ?? '',
      stickerTemplateId: map['template'] ?? '',
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      params: Map<String, dynamic>.from(map['params']),
    );
  }

  String toJson() => json.encode(toMap());

  factory DoorbellSticker.fromJson(String source) => DoorbellSticker.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DoorbellSticker(stickerId: $stickerId, stickerTemplateId: $stickerTemplateId, created: $created, params: $params)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DoorbellSticker &&
        other.stickerId == stickerId &&
        other.stickerTemplateId == stickerTemplateId &&
        other.created == created &&
        mapEquals(other.params, params);
  }

  @override
  int get hashCode {
    return stickerId.hashCode ^ stickerTemplateId.hashCode ^ created.hashCode ^ params.hashCode;
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
