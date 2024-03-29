import 'package:firebase_database/firebase_database.dart';
import 'package:nanoid/nanoid.dart';

class DoorbellEvent implements Comparable<DoorbellEvent> {
  final String eventId;
  final String stickerId;
  final String doorbellId;
  final int eventType;
  final DateTime dateTime;
  final Map? voip;

  List<String> users = <String>[];

  DoorbellEvent._({
    required this.eventId,
    required this.stickerId,
    required this.doorbellId,
    required this.eventType,
    required this.dateTime,
    required this.voip,
  });

  String get formattedStatus {
    if (voip == null) return "Answered";

    switch (voip!['state']) {
      case 'end':
        return voip!['reason'] == 'ok'
            ? 'Answered'
            : voip!['reason'] == 'guest_cant_connect'
                ? 'Cancelled'
                : voip!['reason'] == 'user_not_answered'
                    ? 'Ignored'
                    : voip!['reason'] == 'user_not_available'
                        ? 'Missed'
                        : '';
      default:
        return 'Answered';
    }
  }

  bool get hasDuration {
    return voip?['duration'] != null && voip!['duration'] > 0;
  }

  String get formattedDuration {
    if (hasDuration) {
      var duration = Duration(milliseconds: voip!['duration']);
      if (duration.inSeconds < 60) return "${duration.inSeconds}s";
      if (duration.inMinutes < 60) return "${duration.inMinutes}m";
    }

    return "";
  }

  String? get acceptedBy {
    if (voip?['user']?['sid'] == null || voip?['user']?['answered'] != true) return null;
    return voip?['user']?['sid'];
  }

  static DoorbellEvent create(int eventType, String doorbellId, String stickerId) {
    return DoorbellEvent._(
        eventId: nanoid(10), stickerId: stickerId, doorbellId: doorbellId, eventType: eventType, dateTime: DateTime.now(), voip: {});
  }

  static DoorbellEvent? fromMap(Map s) {
    if (s['t'] != null) return DoorbellEvent.fromMapAndId(s['d'], s['i'], s);
    return null;
  }

  static DoorbellEvent fromMapAndDoorbellId(String doorbellId, Map s) => DoorbellEvent.fromMapAndId(doorbellId, s['i'], s);

  static DoorbellEvent fromMapAndId(String doorbellId, String eventId, Map s) {
    if (s['t'] == DoorbellEventType.textMessage.typeCode) {
      return TextMessageDoorbellEvent._(
        eventId: eventId,
        doorbellId: doorbellId,
        stickerId: s['s'] ?? "",
        textMessage: s['txt'] ?? "",
        dateTime: DateTime.fromMillisecondsSinceEpoch(s['ts']),
        voip: s['voip'],
      )..users = List<String>.from(s['users'] ?? <String>[]);
    }

    if (s['t'] == DoorbellEventType.voiceMessage.typeCode) {
      return VoiceMessageDoorbellEvent._(
        eventId: eventId,
        doorbellId: doorbellId,
        stickerId: s['s'] ?? "",
        recordingLink: s['rec'] ?? "",
        dateTime: DateTime.fromMillisecondsSinceEpoch(s['ts']),
        voip: s['voip'],
      )..users = List<String>.from(s['users'] ?? <String>[]);
    }

    return DoorbellEvent._(
      eventId: eventId,
      doorbellId: doorbellId,
      stickerId: s['s'] ?? "",
      eventType: s['t'] ?? "",
      dateTime: DateTime.fromMillisecondsSinceEpoch(s['ts']),
      voip: s['voip'],
    )..users = List<String>.from(s['users'] ?? <String>[]);
  }

  static DoorbellEvent fromSnapshotAndDoorbellId(String doorbellId, DataSnapshot snapshot) {
    final s = Map.of(snapshot.value as dynamic);
    return DoorbellEvent._(
      eventId: s['i'],
      doorbellId: doorbellId,
      stickerId: s['s'],
      eventType: s['t'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(s['ts']),
      voip: s['voip'],
    )..users = List<String>.from(s['users'] ?? <String>[]);
  }

  static DoorbellEvent fromSnapshot(DataSnapshot snapshot) {
    final s = Map.of(snapshot.value as dynamic);
    return DoorbellEvent._(
        eventId: s['i'],
        doorbellId: s['d'],
        stickerId: s['s'],
        eventType: s['t'],
        dateTime: DateTime.fromMillisecondsSinceEpoch(s['ts']),
        voip: s['voip'])
      ..users = List<String>.from(s['users'] ?? <String>[]);
  }

  Map toMap() => {
        'i': eventId,
        'd': doorbellId,
        's': stickerId,
        't': eventType,
        'ts': dateTime.millisecondsSinceEpoch,
        'voip': voip,
        'users': users,
      };

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

  String get formattedDateTimeSingleLine {
    var now = DateTime.now();
    var weekday = now.weekday;
    var diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return "${diff.inSeconds} seconds ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";

    var hourMin = "${dateTime.hour < 10 ? '0' : ''}${dateTime.hour}:${dateTime.minute < 10 ? '0' : ''}${dateTime.minute}";
    if (diff.inDays == 0) {
      if (now.day == dateTime.day)
        return "today at $hourMin";
      else
        return "yesterday at $hourMin";
    }
    if (diff.inDays < weekday) return "on ${_convertWeekDayLong(dateTime.weekday)} at $hourMin";
    if (dateTime.year < now.year) {
      if (diff.inDays > 365) {
        if (diff.inDays < 730) return "more than a year ago";
        return "more than ${(diff.inDays / 365).round()} years ago";
      }
      return "at ${dateTime.day} ${_convertMonth(dateTime.month)}, ${dateTime.year} $hourMin";
    }
    return "at ${dateTime.day} ${_convertMonth(dateTime.month)} $hourMin";
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

  String _convertWeekDayLong(int weekday) {
    switch (weekday) {
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      case 1:
      default:
        return 'Monday';
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
    required super.voip,
  }) : super._(eventType: DoorbellEventType.textMessage.typeCode);

  @override
  Map toMap() => super.toMap()..['txt'] = textMessage;
}

class VoiceMessageDoorbellEvent extends DoorbellEvent {
  final String recordingLink;

  VoiceMessageDoorbellEvent._({
    required super.eventId,
    required super.doorbellId,
    required super.stickerId,
    required super.dateTime,
    required this.recordingLink,
    required super.voip,
  }) : super._(eventType: DoorbellEventType.voiceMessage.typeCode);

  @override
  Map toMap() => super.toMap()..['rec'] = recordingLink;
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
        return "rings";
      case 2:
        return "missed";
      case 3:
        return "answered";
      case 4:
        return "text message";
      case 5:
        return "voice message";
      case 0:
      default:
        return null;
    }
  }
}
