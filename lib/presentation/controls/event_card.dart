import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String eventName;
  final String eventTime;

  EventCard({
    super.key,
    required this.eventName,
    required this.eventTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                CupertinoIcons.bell,
                size: 24,
                color: Colors.grey,
              )),
          Padding(padding: EdgeInsets.all(5)),
          Text(
            this.eventName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Text(
            this.eventTime,
            style: TextStyle(color: CupertinoColors.inactiveGray),
          ),
        ]),
      ),
    );
  }
}
