import 'dart:io';

import 'package:collection/collection.dart';
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
    final dataStore = DataStore.of(context);
    final canEdit = dataStore.doorbellUsers.items
            .firstWhereOrNull((x) => x.doorbellId == widget.doorbellId && x.userId == dataStore.currentUser?.userId)
            ?.role ==
        'owner';
    return CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.white,
            padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
            leading: IconButton(
              onPressed: onBackButtonTap,
              icon: const Icon(CupertinoIcons.chevron_back, color: CupertinoColors.activeBlue),
            ),
            trailing: canEdit
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onDeleteButtonTap,
                    child: const Text('Delete', style: TextStyle(color: CupertinoColors.destructiveRed)),
                  )
                : null,
            middle: Text(
                "Sticker: ${_stickerEditController.sticker.displayName?.isEmpty == true ? 'new' : _stickerEditController.sticker.displayName}")),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: CupertinoColors.systemGroupedBackground,
                      border: Border.symmetric(vertical: BorderSide(color: CupertinoColors.systemGrey2, width: 1))),
                  child: _stickerEditController.previewWidget),
            ),
            Flexible(
              fit: FlexFit.loose,
              flex: 0,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: CupertinoColors.systemBackground,
                ),
                child: Column(
                  children: [
                    if (canEdit) _stickerEditController.settingsWidget,
                    Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 10),
                        child: CupertinoButton.filled(
                            onPressed: () => Navigator.of(context).waitWithScreenThenPop<StickerInfo>(onPrintButtonTap),
                            child: const Text('Print Sticker', style: TextStyle(fontWeight: FontWeight.bold)))),
                    Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
                        child: const Text('You can print your sticker or save to photos.',
                            style: TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14), textAlign: TextAlign.center)),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void _stickerEditControllerListener() {
    if (mounted) setState(() {});
  }

  Future<void> onUpdateSticker(StickerInfo stickerInfo) async {
    await StickerService().updateSticker(stickerInfo);
  }

  Future<void> printSticker(StickerInfo stickerInfo) async {
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

  Future<StickerInfo?> onPrintButtonTap() async {
    var stickerInfo = _stickerEditController.sticker;
    if (widget.sticker == null) {
      var newSticker = await StickerService().createSticker(widget.handler, widget.templateId, widget.doorbellId, stickerInfo.data.toMap());
      if (newSticker == null) return null;

      await printSticker(newSticker);
      return newSticker;
    } else if (_stickerEditController.isSettingsChanged) {
      await onUpdateSticker(stickerInfo);
      stickerInfo.data.acceptChanges();
    }

    await printSticker(stickerInfo);
    return stickerInfo;
  }

  Future<void> onBackButtonTap() async {
    var nav = Navigator.of(context);
    if (widget.sticker == null && _stickerEditController.isSettingsChanged) {
      var saveChanges = await showDialog<bool>(
          context: context,
          builder: (context) =>
              CupertinoAlertDialog(title: const Text('There are unsaved changes that will be lost.\nDo you want to save them?'), actions: [
                CupertinoDialogAction(
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.of(context).pop(true)),
                CupertinoDialogAction(child: const Text('Discard'), onPressed: () => Navigator.of(context).pop(false)),
              ]));

      if (saveChanges == false) {
        return nav.pop(null);
      }

      var s = await nav.waitWithScreenThenPop<StickerInfo>(() async {
        var newSticker = await StickerService()
            .createSticker(widget.handler, widget.templateId, widget.doorbellId, _stickerEditController.sticker.data.toMap());

        _stickerEditController.sticker.data.clear();
        return newSticker;
      }, false);

      nav.pop(s);
      return;
    }

    if (widget.sticker != null && _stickerEditController.isSettingsChanged) {
      await nav.waitWithScreenThenPop<StickerInfo>(() async {
        await onUpdateSticker(_stickerEditController.sticker);
        _stickerEditController.sticker.data.acceptChanges();

        return _stickerEditController.sticker;
      });

      return;
    }

    return nav.pop(null);
  }

  Future<void> onDeleteButtonTap() async {
    var nav = Navigator.of(context);
    var shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(title: const Text('Are you sure you want to delete this sticker?'), actions: [
              CupertinoDialogAction(child: const Text('Yes'), onPressed: () => Navigator.of(context).pop(true)),
              CupertinoDialogAction(
                  child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(context).pop(false)),
            ]));

    if (shouldDelete == true) {
      nav.waitWithScreenThenPop(() async => await StickerService().deleteSticker(_stickerEditController.sticker));
    }
  }
}
