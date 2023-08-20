import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../model/sticker.dart';
import '../sticker_edit_controller.dart';
import '../../../../services/sticker_handler_factory.dart';
import 'sticker_data.dart';

class StickerV1Service extends StickerHandlerService<StickerV1Data> {
  StickerV1Service() : super(handler: 'sticker_v1', templateIds: ['sticker_v1_vertical', 'sticker_v1_horizontal']);

  @override
  StickerV1Data? parseStickerData(Map? data) => StickerV1Data(data);

  @override
  StickerEditController<StickerV1Data> createEditController(Map? data) => StickerV1Controller(StickerInfo(data ?? {}));
}

class StickerV1Controller extends StickerEditController<StickerV1Data> {
  static void register() {
    StickerHandlerFactory.register<StickerV1Service, StickerV1Data>(StickerV1Service());
  }

  StickerV1Controller(super.settings);

  @override
  Widget createPreviewWidget() => StickerV1Preview.create(controller: this);

  @override
  Widget createSettingsWidget() => StickerV1SettingsWidget(controller: this);

  @override
  StickerV1Data createStickerData(Map? data) => StickerV1Data(data);
}

class StickerV1Preview extends StatefulWidget {
  final StickerEditController<StickerV1Data> controller;
  final Widget templateImageWidget;
  final Widget qrcodeWidget;
  final Widget textWidget;

  factory StickerV1Preview.create({required StickerEditController<StickerV1Data> controller}) => controller.settings.vertical != false
      ? StickerV1Preview._vertical(controller: controller)
      : StickerV1Preview._horizontal(controller: controller);

  factory StickerV1Preview._horizontal({required StickerEditController<StickerV1Data> controller}) {
    return StickerV1Preview._(
        controller: controller,
        templateImageWidget: Image.asset('assets/sticker_yellow_hor/qrdoorbell-sticker-5_horizontal@1x.png', width: 330),
        qrcodeWidget: const Positioned(top: 8, left: 115, child: Icon(CupertinoIcons.qrcode, color: Colors.black, size: 100)),
        textWidget: Positioned(
            width: 90,
            height: 45,
            top: 42,
            left: 15,
            child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.contain,
                child: Text(controller.settings.apt,
                    overflow: TextOverflow.visible, textAlign: TextAlign.center, style: const TextStyle(fontSize: 42)))));
  }

  factory StickerV1Preview._vertical({required StickerEditController<StickerV1Data> controller}) {
    return StickerV1Preview._(
        controller: controller,
        templateImageWidget: Image.asset('assets/sticker_yellow_vert/qrdoorbell-sticker-5@1x.png', width: 130),
        qrcodeWidget: const Positioned(left: 15, top: 130, child: Icon(CupertinoIcons.qrcode, color: Colors.black, size: 100)),
        textWidget: Positioned(
            width: 100,
            height: 45,
            top: 75,
            left: 15,
            child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.contain,
                child: Text(controller.settings.apt,
                    overflow: TextOverflow.visible, textAlign: TextAlign.center, style: const TextStyle(fontSize: 42)))));
  }

  const StickerV1Preview._(
      {required this.controller, required this.templateImageWidget, required this.qrcodeWidget, required this.textWidget});

  @override
  State<StickerV1Preview> createState() => _StickerV1PreviewState();
}

class _StickerV1PreviewState extends State<StickerV1Preview> {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Center(
          child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: CupertinoColors.systemGrey2, blurRadius: 15)]),
              child: Stack(children: [widget.templateImageWidget, widget.qrcodeWidget, widget.textWidget])))
    ]);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  void _controllerListener() {
    setState(() {});
  }
}

class StickerV1SettingsWidget extends StatefulWidget {
  final StickerEditController<StickerV1Data> controller;

  const StickerV1SettingsWidget({super.key, required this.controller});

  @override
  State<StickerV1SettingsWidget> createState() => _StickerV1SettingsWidgetState();
}

class _StickerV1SettingsWidgetState extends State<StickerV1SettingsWidget> {
  final _aptNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _aptNumberController.text = widget.controller.settings.apt;
    _aptNumberController.addListener(_aptNumberControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection(
        backgroundColor: CupertinoColors.white,
        additionalDividerMargin: 6,
        header: const Text(
          'SETTINGS',
          style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
        ),
        children: [
          CupertinoListTile(
              title: CupertinoTextField(
            controller: _aptNumberController,
            decoration: const BoxDecoration(),
            textAlign: TextAlign.right,
            prefix: const Text('Apartment / House'),
            placeholder: 'number / code',
            placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey3),
            maxLength: 4,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onEditingComplete: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          )),
          CupertinoListTile(
              title: const Text('Layout'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(widget.controller.settings.vertical ? 'vertical' : 'horizontal',
                        style: const TextStyle(color: CupertinoColors.systemGrey3))),
                CupertinoSwitch(
                    onChanged: (bool value) => widget.controller.set((settings) => settings.vertical = value),
                    value: widget.controller.settings.vertical,
                    trackColor: CupertinoColors.activeGreen)
              ]))
        ]);
  }

  @override
  void dispose() {
    _aptNumberController.removeListener(_aptNumberControllerListener);
    _aptNumberController.dispose();
    super.dispose();
  }

  void _aptNumberControllerListener() => widget.controller.set((settings) => settings.apt = _aptNumberController.value.text.trim());
}
