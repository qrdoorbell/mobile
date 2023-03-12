import 'package:firebase_database/firebase_database.dart';
import 'package:nanoid/nanoid.dart';

class DoorbellEvent implements Comparable<DoorbellEvent> {
  final String eventId;
  final String stickerId;
  final String doorbellId;
  final int eventType;
  final DateTime dateTime;

  DoorbellEvent._({
    required this.eventId,
    required this.stickerId,
    required this.doorbellId,
    required this.eventType,
    required this.dateTime,
  });

  static DoorbellEvent create(int eventType, String doorbellId, String stickerId) {
    return DoorbellEvent._(
        eventId: nanoid(10), stickerId: stickerId, doorbellId: doorbellId, eventType: eventType, dateTime: DateTime.now());
  }

  static DoorbellEvent fromMap(Map s) {
    return DoorbellEvent.fromMapAndId(s['d'], s['i'], s);
  }

  static DoorbellEvent fromMapAndDoorbellId(String doorbellId, Map s) => DoorbellEvent.fromMapAndId(doorbellId, s['i'], s);

  static DoorbellEvent fromMapAndId(String doorbellId, String eventId, Map s) => DoorbellEvent._(
      eventId: eventId,
      doorbellId: doorbellId,
      stickerId: s['s'],
      eventType: s['t'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(s['ts']));

  static DoorbellEvent fromSnapshotAndDoorbellId(String doorbellId, DataSnapshot snapshot) {
    final s = Map.of(snapshot.value as dynamic);
    return DoorbellEvent._(
        eventId: s['i'],
        doorbellId: doorbellId,
        stickerId: s['s'],
        eventType: s['t'],
        dateTime: DateTime.fromMillisecondsSinceEpoch(s['ts']));
  }

  static DoorbellEvent fromSnapshot(DataSnapshot snapshot) {
    final s = Map.of(snapshot.value as dynamic);
    return DoorbellEvent._(
        eventId: s['i'], doorbellId: s['d'], stickerId: s['s'], eventType: s['t'], dateTime: DateTime.fromMillisecondsSinceEpoch(s['ts']));
  }

  Map toMap() => {
        'i': eventId,
        'd': doorbellId,
        's': stickerId,
        't': eventType,
        'ts': dateTime.millisecondsSinceEpoch,
      };

  factory DoorbellEvent.doorbell(String doorbellId, String stickerId, DateTime? dateTime) => DoorbellEvent._(
      eventId: nanoid(10).toString(),
      doorbellId: doorbellId,
      stickerId: stickerId,
      eventType: DoorbellEventType.doorbell.typeCode,
      dateTime: dateTime ?? DateTime.now());
  factory DoorbellEvent.missedCall(String doorbellId, String stickerId, DateTime? dateTime) => DoorbellEvent._(
      eventId: nanoid(10).toString(),
      doorbellId: doorbellId,
      stickerId: stickerId,
      eventType: DoorbellEventType.missedCall.typeCode,
      dateTime: dateTime ?? DateTime.now());
  factory DoorbellEvent.answeredCall(String doorbellId, String stickerId, DateTime? dateTime) => DoorbellEvent._(
      eventId: nanoid(10).toString(),
      doorbellId: doorbellId,
      stickerId: stickerId,
      eventType: DoorbellEventType.answeredCall.typeCode,
      dateTime: dateTime ?? DateTime.now());
  factory DoorbellEvent.textMessage(String doorbellId, String stickerId, DateTime? dateTime, String textMessage) =>
      TextMessageDoorbellEvent._(
          eventId: nanoid(10).toString(),
          doorbellId: doorbellId,
          stickerId: stickerId,
          dateTime: dateTime ?? DateTime.now(),
          textMessage: textMessage);
  factory DoorbellEvent.voiceMessage(String doorbellId, String stickerId, DateTime? dateTime) => DoorbellEvent._(
      eventId: nanoid(10).toString(),
      doorbellId: doorbellId,
      stickerId: stickerId,
      eventType: DoorbellEventType.voiceMessage.typeCode,
      dateTime: dateTime ?? DateTime.now());

  String get formattedDateTime {
    var now = DateTime.now();
    var weekday = now.weekday;
    var diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";

    var hourMin = "${dateTime.hour < 10 ? '0' : ''}${dateTime.hour}:${dateTime.minute < 10 ? '0' : ''}${dateTime.minute}";
    if (diff.inDays == 0) return hourMin;
    if (diff.inDays < weekday) return "${_convertWeekDay(dateTime.weekday)}, $hourMin";
    if (dateTime.year < now.year) {
      return "${dateTime.day} ${_convertMonth(dateTime.month)} ${dateTime.year}\n$hourMin";
    }
    return "${dateTime.day} ${_convertMonth(dateTime.month)}, $hourMin";
  }

  String get formattedName => DoorbellEventType.getString(eventType) ?? "Unknown event";

  String _convertWeekDay(int weekday) {
    switch (weekday) {
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      case 1:
      default:
        return 'Mon';
    }
  }

  String _convertMonth(int month) {
    switch (month) {
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      case 1:
      default:
        return 'Jan';
    }
  }

  @override
  String toString() =>
      'DoorbellEvent(eventId: $eventId, eventType: $eventType, doorbellId: $doorbellId, stickerId: $stickerId, dateTime: $dateTime)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DoorbellEvent &&
        other.eventId == eventId &&
        other.eventType == eventType &&
        other.doorbellId == doorbellId &&
        other.stickerId == stickerId &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode => eventId.hashCode ^ eventType.hashCode ^ doorbellId.hashCode ^ stickerId.hashCode ^ dateTime.hashCode;

  @override
  int compareTo(DoorbellEvent other) {
    return other.dateTime.isBefore(dateTime) ? -1 : 1;
  }
}

class TextMessageDoorbellEvent extends DoorbellEvent {
  final String textMessage;

  TextMessageDoorbellEvent._({
    required super.eventId,
    required super.doorbellId,
    required super.stickerId,
    required super.dateTime,
    required this.textMessage,
  }) : super._(eventType: DoorbellEventType.textMessage.typeCode);
}

enum DoorbellEventType {
  unknown(0),
  doorbell(1),
  missedCall(2),
  answeredCall(3),
  textMessage(4),
  voiceMessage(5);

  const DoorbellEventType(this.typeCode);

  final int typeCode;

  @override
  String toString() => DoorbellEventType.getString(typeCode) ?? 'Unknown event';

  static String? getString(int? typeCode) {
    switch (typeCode) {
      case 1:
        return "Doorbell rings";
      case 2:
        return "Missed call";
      case 3:
        return "Answered call";
      case 4:
        return "Text message";
      case 5:
        return "Voice message";
      case 0:
      default:
        return null;
    }
  }
}
