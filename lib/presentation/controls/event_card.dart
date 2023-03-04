import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrdoorbell_mobile/data.dart';

class EventCard extends StatelessWidget {
  final DoorbellEvent event;

  EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    var dataStore = Provider.of<DataStore>(context);
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
                    _getEventIcon(),
                    size: 24,
                    color: Colors.grey,
                  )),
              Padding(padding: EdgeInsets.all(5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventType.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                  ),
                  Text(
                    dataStore.getDoorbellById(event.doorbellId)?.name ?? '-',
                    style: TextStyle(color: CupertinoColors.inactiveGray),
                  ),
                ],
              ),
              Spacer(),
              Text(
                event.formattedDateTime,
                style: TextStyle(color: CupertinoColors.inactiveGray),
                textAlign: TextAlign.right,
              ),
            ]),
          ),
        ));
  }

  IconData _getEventIcon() {
    switch (event.eventType.typeCode) {
      case 1:
        return CupertinoIcons.bell;
      case 2:
        return CupertinoIcons.phone;
      case 3:
        return CupertinoIcons.phone;
      case 4:
        return CupertinoIcons.chat_bubble_text;
      case 5:
        return CupertinoIcons.recordingtape;
      case 0:
      default:
        return CupertinoIcons.question;
    }
  }
}
