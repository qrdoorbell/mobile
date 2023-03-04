import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrdoorbell_mobile/data.dart';

import '../../routing/route_state.dart';

class EventCard extends StatelessWidget {
  final DoorbellEvent event;
  final bool showDoorbellLink;

  EventCard({
    super.key,
    required this.event,
    this.showDoorbellLink = true,
  });

  @override
  Widget build(BuildContext context) {
    var dataStore = Provider.of<DataStore>(context);
    var doorbell = dataStore.getDoorbellById(event.doorbellId);

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
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white70,
                      border: Border.fromBorderSide(BorderSide(width: 1, color: Colors.grey.shade200))),
                  width: 48,
                  height: 48,
                  child: Icon(
                    _getEventIcon(),
                    size: 24,
                    color: CupertinoColors.systemGrey,
                  )),
              Padding(padding: EdgeInsets.all(5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventType.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (showDoorbellLink && doorbell != null)
                    Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: CupertinoButton(
                          borderRadius: BorderRadius.zero,
                          minSize: 0,
                          padding: EdgeInsets.zero,
                          child: Text(
                            doorbell.name,
                            style: TextStyle(fontSize: 14, color: CupertinoColors.activeBlue),
                          ),
                          onPressed: () async => await RouteStateScope.of(context).go('/doorbells/${event.doorbellId}'),
                        )),
                  if (showDoorbellLink && doorbell == null)
                    Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text('--', style: TextStyle(fontSize: 14, color: CupertinoColors.inactiveGray)))
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
