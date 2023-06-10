import 'package:flutter/cupertino.dart';
import '../../app_options.dart';
import '../../tools.dart';
import '../screens/empty_screen.dart';
import '../../routing.dart';

class QRCodeScreen extends StatelessWidget {
  final String doorbellId;
  final VoidCallback? onPrintStickerCallback;

  const QRCodeScreen({super.key, required this.doorbellId, this.onPrintStickerCallback});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: (() async {
      var imgResp = await HttpUtils.secureGet(Uri.parse('$QRDOORBELL_API_URL/api/v1/doorbells/$doorbellId/qr/'));
      if (imgResp.statusCode != 200) {
        throw FlutterError('ERROR: unable to download image: responseCode=${imgResp.statusCode}');
      }

      return imgResp.bodyBytes;
    })(), builder: (context, snapshot) {
      Widget child;
      bool showSaveButton = true;
      if (snapshot.hasError) {
        showSaveButton = false;
        child = Column(children: [
          const Padding(padding: EdgeInsets.all(8)),
          const Text('Error occured!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          const Padding(padding: EdgeInsets.all(12)),
          const Text('Server returns non success result code.'),
          const Padding(padding: EdgeInsets.all(8)),
          const Text('Please reach out support team for more details.'),
          const Padding(padding: EdgeInsets.all(20)),
          CupertinoButton.filled(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back')),
        ]);
      } else if (!snapshot.hasData)
        return EmptyScreen.white().withWaitingIndicator();
      else
        child = Image.memory(snapshot.data!);

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
              if (showSaveButton) ...[
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
              ],
              const Padding(padding: EdgeInsets.all(20))
            ]),
          ));
    });
  }
}
