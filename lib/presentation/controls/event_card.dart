import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String eventName;
  final String eventTime;
  final IconData iconData;

  EventCard({
    super.key,
    required this.eventName,
    required this.eventTime,
    required this.iconData,
  });

  factory EventCard.fromDoorbellEvent(String eventTime) =>
      EventCard(eventName: 'Doorbell', eventTime: eventTime, iconData: CupertinoIcons.bell);

  factory EventCard.fromMissedCallEvent(String eventTime) =>
      EventCard(eventName: 'Missed call', eventTime: eventTime, iconData: CupertinoIcons.phone);

  factory EventCard.fromAnsweredCallEvent(String eventTime) =>
      EventCard(eventName: 'Answered call', eventTime: eventTime, iconData: CupertinoIcons.phone);

  factory EventCard.fromVoiceMessageEvent(String eventTime) =>
      EventCard(eventName: 'Voice message', eventTime: eventTime, iconData: CupertinoIcons.recordingtape);

  factory EventCard.fromTextMessageEvent(String eventTime) =>
      EventCard(eventName: 'Text message', eventTime: eventTime, iconData: CupertinoIcons.chat_bubble_text);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 15, top: 5, right: 10),
        child: Card(
          shadowColor: Colors.transparent,
          color: CupertinoColors.extraLightBackgroundGray.withAlpha(128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(children: [
              Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  width: 48,
                  height: 48,
                  child: Icon(
                    iconData,
                    size: 24,
                    color: Colors.grey,
                  )),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                eventName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                eventTime,
                style: TextStyle(color: CupertinoColors.inactiveGray),
              ),
            ]),
          ),
        ));
  }
}
