import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EmptyScreen extends StatelessWidget {
  final bool isBlack;

  const EmptyScreen([this.isBlack = true]);

  @override
  Widget build(BuildContext context) {
    if (isBlack)
      return Scaffold(
          backgroundColor: CupertinoColors.darkBackgroundGray,
          body: Center(
              child: SvgPicture.asset(
            'assets/logo-app-white.svg',
            width: 120,
            height: 120,
          )));

    return Scaffold(
        backgroundColor: CupertinoColors.white,
        body: Center(
            child: SvgPicture.asset(
          'assets/logo-app.svg',
          width: 120,
          height: 120,
        )));
  }
}
