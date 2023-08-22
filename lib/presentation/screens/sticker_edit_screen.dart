import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data.dart';
import '../../services/sticker_service.dart';
import '../../tools.dart';
import '../controls/stickers/sticker_edit_controller.dart';
import '../../services/sticker_handler_factory.dart';

class StickerEditScreen extends StatefulWidget {
  final String handler;
  final String doorbellId;
  final StickerInfo? sticker;
  final String? templateId;

  const StickerEditScreen({super.key, required this.handler, required this.doorbellId, this.sticker, this.templateId});

  @override
  State<StickerEditScreen> createState() => _StickerEditScreenState();
}

class _StickerEditScreenState extends State<StickerEditScreen> {
  late final StickerEditController _stickerEditController;

  @override
  void initState() {
    super.initState();
    _stickerEditController = StickerHandlerFactory.createEditController(widget.handler, widget.sticker);
    _stickerEditController.addListener(_stickerEditControllerListener);
  }

  @override
  void dispose() {
    _stickerEditController.removeListener(_stickerEditControllerListener);
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
                onPressed: () async {
                  var nav = Navigator.of(context);
                  if (widget.sticker == null && _stickerEditController.isSettingsChanged) {
                    var saveChanges = await showDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                                title: const Text('There are unsaved changes that will be lost.\nDo you want to save them?'),
                                actions: [
                                  CupertinoDialogAction(
                                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                                      onPressed: () => Navigator.of(context).pop(true)),
                                  CupertinoDialogAction(child: const Text('Discard'), onPressed: () => Navigator.of(context).pop(false)),
                                ]));
                    if (saveChanges == false) {
                      return nav.pop(null);
                    }

                    var newSticker = await StickerService()
                        .createSticker(widget.handler, widget.templateId, widget.doorbellId, _stickerEditController.sticker.data.toMap());
                    return nav.pop(newSticker);
                  }

                  var stickerInfo = _stickerEditController.sticker;
                  nav.pop(stickerInfo);

                  if (widget.sticker != null && _stickerEditController.isSettingsChanged) await _updateSticker(stickerInfo);
                },
                color: CupertinoColors.activeBlue),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                var nav = Navigator.of(context);
                var shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) =>
                        CupertinoAlertDialog(title: const Text('Are you sure you want to delete this sticker?'), actions: [
                          CupertinoDialogAction(child: const Text('Yes'), onPressed: () => Navigator.of(context).pop(true)),
                          CupertinoDialogAction(
                              child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => Navigator.of(context).pop(false)),
                        ]));

                if (shouldDelete == true) {
                  nav.waitWithScreenThenPop(() async => await StickerService().deleteSticker(_stickerEditController.sticker));
                }
              },
              child: const Text('Delete', style: TextStyle(color: CupertinoColors.destructiveRed)),
            ),
            middle: Text(
                "Sticker: ${_stickerEditController.sticker.displayName?.isEmpty == true ? 'new' : _stickerEditController.sticker.displayName}")),
        child: Container(
            color: CupertinoColors.white,
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child: Container(
                      color: CupertinoColors.systemGroupedBackground,
                      child: Container(
                          height: 400,
                          clipBehavior: Clip.hardEdge,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                              color: CupertinoColors.systemGroupedBackground,
                              border: Border.symmetric(vertical: BorderSide(color: CupertinoColors.systemGrey3, width: 1))),
                          child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runAlignment: WrapAlignment.center,
                              children: [_stickerEditController.previewWidget])))),
              _stickerEditController.settingsWidget,
              const Spacer(),
              Flexible(
                  flex: 0,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40, top: 0, bottom: 0),
                        child: CupertinoButton.filled(
                            onPressed: () async {
                              Navigator.of(context).waitWithScreenThenPop<StickerInfo>(() async {
                                var stickerInfo = _stickerEditController.sticker;
                                if (widget.sticker == null) {
                                  var newSticker = await StickerService()
                                      .createSticker(widget.handler, widget.templateId, widget.doorbellId, stickerInfo.data.toMap());

                                  if (newSticker == null) return null;

                                  await _printHandler(newSticker);
                                  return newSticker;
                                } else if (_stickerEditController.isSettingsChanged) await _updateSticker(stickerInfo);

                                await _printHandler(stickerInfo);
                                return stickerInfo;
                              });
                            },
                            child: const Text('Print Sticker', style: TextStyle(fontWeight: FontWeight.bold)))),
                    const Padding(padding: EdgeInsets.all(5)),
                    const Text('You can print your sticker or save to photos.',
                        style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14), textAlign: TextAlign.center),
                    const Padding(padding: EdgeInsets.only(bottom: 20))
                  ]))
            ])));
  }

  void _stickerEditControllerListener() {
    if (mounted) setState(() {});
  }

  Future<void> _updateSticker(StickerInfo stickerInfo) async => await StickerService().updateSticker(stickerInfo);

  static Future<void> _printHandler(StickerInfo stickerInfo) async {
    var stickerPrint = await StickerService().getStickerPdf(stickerInfo.doorbellId, stickerInfo.stickerId);
    var tempDir = await Directory.systemTemp.createTemp();
    try {
      var stickerFile = await File('${tempDir.path}/sticker_${stickerInfo.displayName}.pdf').writeAsBytes(stickerPrint);
      await Share.shareXFiles([
        XFile(stickerFile.path),
      ], subject: '[QR Doorbell] Stricker - ${stickerInfo.displayName}');
    } finally {
      await tempDir.delete(recursive: true);
    }
  }
}
