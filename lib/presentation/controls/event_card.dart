import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/data.dart';

import '../../routing/route_state.dart';

class EventCard extends StatelessWidget {
  final DoorbellEvent event;
  final bool showDoorbellLink;

  const EventCard({
    super.key,
    required this.event,
    this.showDoorbellLink = true,
  });

  @override
  Widget build(BuildContext context) {
    var doorbell = DataStore.of(context).getDoorbellById(event.doorbellId);
    return Padding(
        padding: const EdgeInsets.only(left: 15, top: 5, right: 10),
        child: Card(
          shadowColor: Colors.transparent,
          color: CupertinoColors.extraLightBackgroundGray.withAlpha(128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
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
              const Padding(padding: EdgeInsets.all(5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      doorbell != null
                          ? CupertinoButton(
                              borderRadius: BorderRadius.zero,
                              minSize: 0,
                              padding: EdgeInsets.zero,
                              child: Text(
                                doorbell.name,
                                style: const TextStyle(fontSize: 14, color: CupertinoColors.activeBlue),
                              ),
                              onPressed: () async => await RouteStateScope.of(context).go('/doorbells/${event.doorbellId}'),
                            )
                          : const Text(
                              "Doorbell",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                      Text(" ${event.formattedName}"),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Text(event.formattedStatus),
                          Text(event.getFormattedDuration(', duration: ')),
                        ],
                      ))
                ],
              ),
              const Spacer(),
              Text(
                event.formattedDateTime,
                style: const TextStyle(color: CupertinoColors.inactiveGray),
                textAlign: TextAlign.right,
              ),
            ]),
          ),
        ));
  }

  IconData _getEventIcon() {
    switch (event.eventType) {
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
