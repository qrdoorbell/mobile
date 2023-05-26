import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EmptyScreen extends StatelessWidget {
  final bool isBlack;
  final Widget child;

  const EmptyScreen({
    required this.child,
    this.isBlack = true,
  });

  EmptyScreen withChild(Widget child) => EmptyScreen(isBlack: isBlack, child: child);
  EmptyScreen withBlackBackground() => isBlack ? this : EmptyScreen(isBlack: true, child: child);
  EmptyScreen withWhiteBackground() => !isBlack ? this : EmptyScreen(isBlack: false, child: child);
  EmptyScreen withText(String text) => withChild(Text(text));
  EmptyScreen withWaitingIndicator() =>
      withChild(LoadingAnimationWidget.staggeredDotsWave(color: isBlack ? Colors.white : CupertinoColors.darkBackgroundGray, size: 120));

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
          Padding(padding: const EdgeInsets.all(20), child: child),
        ])));
  }

  factory EmptyScreen.black() => const EmptyScreen(isBlack: true, child: Padding(padding: EdgeInsets.zero));
  factory EmptyScreen.white() => const EmptyScreen(isBlack: false, child: Padding(padding: EdgeInsets.zero));
}
