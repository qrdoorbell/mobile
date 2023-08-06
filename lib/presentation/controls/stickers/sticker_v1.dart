import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model/sticker.dart';
import 'sticker_template.dart';

class StickerV1Preview extends StatefulWidget {
  final StickerEditController controller;
  final Widget templateImageWidget;
  final Widget qrcodeWidget;
  final Widget textWidget;

  factory StickerV1Preview.create({required StickerEditController controller}) => controller.getValue<bool>('vertical') != false
      ? StickerV1Preview._vertical(controller: controller)
      : StickerV1Preview._horizontal(controller: controller);

  factory StickerV1Preview._horizontal({required StickerEditController controller}) {
    final text = controller.getValue<String>('apt') ?? '';
    final double scaleFactor = text.length > 3
        ? 0.75
        : text.length < 3
            ? 1.25
            : 1;

    return StickerV1Preview._(
      controller: controller,
      templateImageWidget: Image.asset('assets/sticker_yellow_hor/qrdoorbell-sticker-5_horizontal@1x.png', width: 330),
      qrcodeWidget: const Positioned(
          top: 8,
          left: 115,
          child: Icon(
            CupertinoIcons.qrcode,
            color: Colors.black,
            size: 100,
          )),
      textWidget: Positioned(
          width: 120,
          top: 40 + 20 * (1 - scaleFactor),
          left: -2,
          child: Text(text,
              overflow: TextOverflow.fade,
              textScaleFactor: scaleFactor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 38,
              ))),
    );
  }

  factory StickerV1Preview._vertical({required StickerEditController controller}) {
    final text = controller.getValue<String>('apt') ?? '';
    final double scaleFactor = text.length > 3
        ? 0.75
        : text.length < 3
            ? 1.25
            : 1;

    return StickerV1Preview._(
      controller: controller,
      templateImageWidget: Image.asset('assets/sticker_yellow_vert/qrdoorbell-sticker-5@1x.png', width: 130),
      qrcodeWidget: const Positioned(
          left: 15,
          top: 130,
          child: Icon(
            CupertinoIcons.qrcode,
            color: Colors.black,
            size: 100,
          )),
      textWidget: Positioned(
          width: 135,
          top: 74 + 20 * (1 - scaleFactor),
          left: -2,
          child: Text(text,
              overflow: TextOverflow.clip,
              textScaleFactor: scaleFactor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 38,
              ))),
    );
  }

  const StickerV1Preview._(
      {required this.controller, required this.templateImageWidget, required this.qrcodeWidget, required this.textWidget});

  @override
  State<StickerV1Preview> createState() => _StickerV1PreviewState();
}

class _StickerV1PreviewState extends State<StickerV1Preview> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: CupertinoColors.systemGrey2,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Stack(
              children: [
                widget.templateImageWidget,
                widget.qrcodeWidget,
                widget.textWidget,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StickerV1SettingsWidget extends StatefulWidget {
  final StickerEditController controller;

  const StickerV1SettingsWidget({Key? key, required this.controller}) : super(key: key);

  @override
  State<StickerV1SettingsWidget> createState() => _StickerV1SettingsWidgetState();
}

class _StickerV1SettingsWidgetState extends State<StickerV1SettingsWidget> {
  final _aptNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      widget.controller.getValue('vertical', defaultValue: true)! == true ? 'vertical' : 'horizontal',
                      style: const TextStyle(color: CupertinoColors.systemGrey3),
                    )),
                CupertinoSwitch(
                  onChanged: (bool value) => widget.controller.setValue('vertical', value),
                  value: widget.controller.getValue('vertical', defaultValue: true)!,
                  trackColor: CupertinoColors.activeGreen,
                ),
              ],
            )),
      ],
    );
  }

  @override
  void dispose() {
    _aptNumberController.removeListener(_aptNumberControllerListener);
    _aptNumberController.dispose();
    super.dispose();
  }

  void _aptNumberControllerListener() {
    widget.controller.setValue('apt', _aptNumberController.value.text);
  }
}

class StickerV1Controller extends StickerEditController<StickerV1SettingsData> {
  static void register() {
    StickersService()
      ..register<StickerV1Controller>('sticker_v1', (data) => StickerV1Controller(StickerV1SettingsData.fromData(data)))
      ..register<StickerV1Controller>('v1_vertical', (data) => StickerV1Controller(StickerV1SettingsData.fromData(data)))
      ..register<StickerV1Controller>('v1_horizontal', (data) => StickerV1Controller(StickerV1SettingsData.fromData(data)));
  }

  StickerV1Controller(super.settings);

  @override
  Widget createPreviewWidget() => StickerV1Preview.create(controller: this);

  @override
  Widget createSettingsWidget() => StickerV1SettingsWidget(controller: this);
}

mixin _StickerV1SettingsData on StickerTemplateData {
  String get text => get('apt', '')!;
  set text(value) => set('apt', value);

  bool get isVertical => get('vertical', true)!;
  set isVertical(value) => set('vertical', value);
}

class StickerV1SettingsData extends StickerTemplateData with _StickerV1SettingsData {
  StickerV1SettingsData._({required String handler, required Map data, required Map params})
      : super(handler: handler, data: data, params: params);

  StickerV1SettingsData() : super(handler: 'sticker_v1', data: {}, params: {'vertical': true});

  factory StickerV1SettingsData.fromData(StickerTemplateData? data) => data != null
      ? StickerV1SettingsData._(
          handler: 'sticker_v1',
          data: data.data,
          params: data.params,
        )
      : StickerV1SettingsData();
}
