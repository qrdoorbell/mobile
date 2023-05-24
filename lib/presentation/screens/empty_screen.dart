import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EmptyScreen extends StatelessWidget {
  final bool isBlack;
  final String text;

  const EmptyScreen([this.isBlack = true, this.text = '']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isBlack ? CupertinoColors.darkBackgroundGray : Colors.white,
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          SvgPicture.asset(
            isBlack ? 'assets/logo-app-white.svg' : 'assets/logo-app.svg',
            width: 120,
            height: 120,
          ),
          const Padding(padding: EdgeInsets.all(20)),
          Text(text),
        ])));
  }

  factory EmptyScreen.white([String text = '']) => EmptyScreen(false, text);
}
