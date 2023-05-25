import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EmptyScreen extends StatelessWidget {
  bool _isBlack = true;
  Widget? _child;

  EmptyScreen();

  EmptyScreen withBlackBackground() {
    _isBlack = true;
    return this;
  }

  EmptyScreen withWhiteBackground() {
    _isBlack = false;
    return this;
  }

  EmptyScreen withText(String text) {
    _child = Text(text);
    return this;
  }

  EmptyScreen withChild(Widget child) {
    _child = child;
    return this;
  }

  EmptyScreen withWaitingIndicator() {
    _child = LoadingAnimationWidget.staggeredDotsWave(color: _isBlack ? Colors.white : CupertinoColors.darkBackgroundGray, size: 120);
    return this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _isBlack ? CupertinoColors.darkBackgroundGray : Colors.white,
        body: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          SvgPicture.asset(
            _isBlack ? 'assets/logo-app-white.svg' : 'assets/logo-app.svg',
            width: 120,
            height: 120,
          ),
          if (_child != null) Padding(padding: const EdgeInsets.all(20), child: _child!),
        ])));
  }

  factory EmptyScreen.black() => EmptyScreen()..withBlackBackground();
  factory EmptyScreen.white() => EmptyScreen()..withWhiteBackground();
}
