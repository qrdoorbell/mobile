import 'package:flutter/cupertino.dart';

import '../../routing/route_state.dart';
import '../controls/stickers/sticker_template.dart';

class StickerEditScreen extends StatefulWidget {
  final String doorbellId;
  final String stickerTemplateId;

  const StickerEditScreen({super.key, required this.doorbellId, required this.stickerTemplateId});

  @override
  State<StickerEditScreen> createState() => _StickerEditScreenState();
}

class _StickerEditScreenState extends State<StickerEditScreen> {
  late final StickerEditController _stickerEditController;

  @override
  void initState() {
    super.initState();
    _stickerEditController = StickerEditControllers.create(widget.stickerTemplateId);
    _stickerEditController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _stickerEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}'),
            color: CupertinoColors.activeBlue,
          ),
        ),
        child: Container(
            color: CupertinoColors.white,
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: CupertinoColors.systemGroupedBackground,
                child: SizedBox(height: 380, child: _stickerEditController.previewWidget),
              ),
              _stickerEditController.settingsWidget,
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 0),
                child: CupertinoButton.filled(
                    onPressed: () {
                      // RouteStateScope.of(context).wait(context.dataStore.signOut(), destinationRoute: "/login");
                    },
                    child: const Text(
                      "Print Sticker",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              const Text(
                'You can print your sticker or save to photos.',
                style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 30)),
            ])));
  }
}
