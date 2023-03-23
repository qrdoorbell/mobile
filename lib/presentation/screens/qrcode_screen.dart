import 'package:flutter/cupertino.dart';
import 'package:qrdoorbell_mobile/routing.dart';

class QRCodeScreen extends StatelessWidget {
  final String doorbellId;

  const QRCodeScreen(this.doorbellId);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => RouteStateScope.of(context).go('/doorbells/$doorbellId'),
            color: CupertinoColors.activeBlue,
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Image.network(
                'https://api.qrdoorbell.io/api/v1/qr/$doorbellId',
              )),
          const Spacer(),
          CupertinoButton.filled(
              onPressed: () => print('PRINT DOORBELL $doorbellId'),
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
        ]));
  }
}
