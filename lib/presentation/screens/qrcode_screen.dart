import 'package:flutter/cupertino.dart';
import '../screens/empty_screen.dart';
import '../../routing.dart';

class QRCodeScreen extends StatelessWidget {
  final String doorbellId;
  final VoidCallback? onPrintStickerCallback;

  const QRCodeScreen({super.key, required this.doorbellId, this.onPrintStickerCallback});

  @override
  Widget build(BuildContext context) {
    return Image.network('https://api.qrdoorbell.io/api/v1/qr/$doorbellId', frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
      if (frame == null) return EmptyScreen.white().withWaitingIndicator();

      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.white,
            padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => RouteStateScope.of(context).go('/doorbells/$doorbellId'),
              color: CupertinoColors.activeBlue,
            ),
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(padding: const EdgeInsets.all(20), child: child),
              const Spacer(),
              CupertinoButton.filled(
                  onPressed: () => onPrintStickerCallback?.call(),
                  child: const Text(
                    'Save sticker image',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              const Padding(padding: EdgeInsets.all(10)),
              const Text(
                'You can print your sticker or save to photos.',
                style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14),
              ),
              const Padding(padding: EdgeInsets.all(20))
            ]),
          ));
    });
  }
}
