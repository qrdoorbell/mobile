import 'package:flutter/material.dart';

class StickerCard extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback? onPressed;
  final double width;

  const StickerCard({
    super.key,
    required this.color,
    required this.child,
    this.width = 96,
    this.onPressed,
  });

  factory StickerCard.fromIconData(IconData iconData, Color color, VoidCallback? onPressed) {
    return StickerCard(
        color: color,
        onPressed: onPressed,
        child: Icon(
          size: 64,
          iconData,
          color: Colors.white,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Card(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            alignment: AlignmentDirectional.center,
            width: width,
            height: 96,
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ));
  }
}
