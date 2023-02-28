import 'package:flutter/material.dart';

class StickerCard extends StatelessWidget {
  final Color color;
  final Widget child;

  StickerCard({
    super.key,
    required this.color,
    required this.child,
  });

  factory StickerCard.fromIcon(IconData iconData, Color color) {
    return StickerCard(
        color: color,
        child: Icon(
          size: 64,
          iconData,
          color: Colors.white,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        alignment: AlignmentDirectional.center,
        width: 96,
        height: 96,
        padding: EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}
