import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';
import '../../app_options.dart';
import '../../tools.dart';
import '../../routing.dart';
import '../screens/empty_screen.dart';

class QRCodeScreen extends StatelessWidget {
  static final logger = Logger('HttpUtils');

  final String doorbellId;

  const QRCodeScreen({super.key, required this.doorbellId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: (() async {
      var imgResp = await HttpUtils.secureGet(Uri.parse('${AppSettings.apiUrl}/api/v1/doorbells/$doorbellId/qr'));
      if (imgResp.statusCode != 200) {
        logger.warning('ERROR: unable to download image: responseCode=${imgResp.statusCode}');
        throw FlutterError('ERROR: unable to download image: responseCode=${imgResp.statusCode}');
      }

      return imgResp.bodyBytes;
    })(), builder: (context, snapshot) {
      Widget child;
      bool showSaveButton = false;
      if (snapshot.hasError) {
        logger.warning('ERROR - unable to get QR code image: ${snapshot.error}');

        showSaveButton = false;
        child = const Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(padding: EdgeInsets.all(8)),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text('Error occured!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: Text('Server returns non success result code!'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Wrap(
              children: [
                Text(
                  'Please reach out our support team for help or try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14),
                ),
              ],
            ),
          ),
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
              onPressed: () => Navigator.of(context).pop(),
              color: CupertinoColors.activeBlue,
            ),
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(padding: const EdgeInsets.all(20), child: child),
              const Spacer(),
              if (showSaveButton && !snapshot.hasError) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoButton.filled(
                      onPressed: () async => await RouteStateScope.of(context).wait(
                          Share.shareXFiles(
                              [XFile.fromData(Uint8List.fromList(snapshot.data!.toList(growable: false)), mimeType: 'image/png')],
                              subject: 'Doorbell'),
                          destinationRoute: '/doorbells/$doorbellId'),
                      child: const Text(
                        'Save sticker image',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                const Text(
                  'You can print your sticker or save to photos.',
                  style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14),
                ),
              ],
              if (!showSaveButton || snapshot.hasError) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Back',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ),
              ],
              const Padding(padding: EdgeInsets.all(20))
            ]),
          ));
    });
  }
}
