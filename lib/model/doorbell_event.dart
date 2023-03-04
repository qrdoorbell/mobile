import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class DoorbellEvent {
  final String eventId;
  final String doorbellId;
  final DoorbellEventType eventType;
  final DateTime dateTime;

  DoorbellEvent._({
    required this.eventId,
    required this.doorbellId,
    required this.eventType,
    required this.dateTime,
  });

  factory DoorbellEvent.fromSnapshot(DataSnapshot snapshot) {
    final s = snapshot.value as Map<String, dynamic>;
    return DoorbellEvent._(eventId: s['eventId'], doorbellId: s['doorbellId'], eventType: s['eventType'], dateTime: s['dateTime']);
  }

  factory DoorbellEvent.doorbell(String doorbellId, DateTime? dateTime) => DoorbellEventType.doorbell.createEvent(doorbellId, dateTime);
  factory DoorbellEvent.missedCall(String doorbellId, DateTime? dateTime) => DoorbellEventType.missedCall.createEvent(doorbellId, dateTime);
  factory DoorbellEvent.answeredCall(String doorbellId, DateTime? dateTime) =>
      DoorbellEventType.answeredCall.createEvent(doorbellId, dateTime);
  factory DoorbellEvent.textMessage(String doorbellId, DateTime? dateTime) =>
      DoorbellEventType.textMessage.createEvent(doorbellId, dateTime);
  factory DoorbellEvent.voiceMessage(String doorbellId, DateTime? dateTime) =>
      DoorbellEventType.voiceMessage.createEvent(doorbellId, dateTime);

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
      return "${dateTime.day} ${_convertMonth(dateTime.month)} ${dateTime.year}\n$hourMin:${dateTime.second < 10 ? '0' : ''}${dateTime.second}";
    }
    return "${dateTime.day} ${_convertMonth(dateTime.month)}, $hourMin";
  }

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
  String toString() {
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
        return "Unknown";
    }
  }

  DoorbellEvent createEvent(String doorbellId, DateTime? dateTime) {
    return DoorbellEvent._(eventId: Uuid().toString(), doorbellId: doorbellId, eventType: this, dateTime: dateTime ?? DateTime.now());
  }
}
