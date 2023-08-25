import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import '../../../../services/sticker_handler_factory.dart';
import '../../../../model/sticker.dart';
import '../sticker_edit_controller.dart';
import 'sticker_data.dart';
import 'sticker_icon.dart';
import 'sticker_v11_preview.dart';

class StickerV1Service extends StickerHandlerService<StickerV1Data> {
  StickerV1Service() : super(handler: 'sticker_v1', templateIds: ['sticker_v1_vertical', 'sticker_v1_horizontal']);

  @override
  StickerV1Data getStickerData(StickerInfo sticker) {
    sticker.raw['data'] ??= StickerV1Data.defaultData;
    return StickerV1Data(sticker.raw['data']);
  }

  @override
  StickerEditController<StickerV1Data> createEditController(StickerInfo<StickerV1Data>? sticker) =>
      StickerV1Controller(sticker ?? StickerInfo<StickerV1Data>({'handler': 'sticker_v1', 'data': StickerV1Data.defaultData}));

  @override
  Widget getStickerIconWidget(StickerInfo sticker, void Function()? onPressed) =>
      StickerV1Icon(stickerData: sticker.data as StickerV1Data, onPressed: onPressed);

  @override
  StickerInfo<StickerV1Data> createStickerInfo(Map data) => StickerInfo<StickerV1Data>(data);
}

class StickerV1Controller extends StickerEditController<StickerV1Data> {
  static void register() {
    StickerHandlerFactory.register<StickerV1Service, StickerV1Data>(StickerV1Service());
  }

  StickerV1Controller(super.sticker);

  @override
  Widget createPreviewWidget() => StickerV11Preview.create(controller: this);

  @override
  Widget createSettingsWidget() => StickerV1SettingsWidget(controller: this);
}

class StickerV1SettingsWidget extends StatefulWidget {
  final StickerEditController<StickerV1Data> controller;

  const StickerV1SettingsWidget({super.key, required this.controller});

  @override
  State<StickerV1SettingsWidget> createState() => _StickerV1SettingsWidgetState();
}

class _StickerV1SettingsWidgetState extends State<StickerV1SettingsWidget> {
  final _aptNumberController = TextEditingController();
  bool _showColorPicker = false;

  @override
  void initState() {
    super.initState();
    _aptNumberController.text = widget.controller.sticker.data.apt;
    _aptNumberController.addListener(onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection(
        backgroundColor: CupertinoColors.white,
        additionalDividerMargin: 6,
        header: const Text(
          'SETTINGS',
          style: TextStyle(fontSize: 15.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
        ),
        children: [
          CupertinoListTile(
              title: CupertinoTextField(
            controller: _aptNumberController,
            decoration: const BoxDecoration(),
            textAlign: TextAlign.right,
            prefix: const Row(
              children: [
                Text('Text'),
                SizedBox(width: 10),
                Text('(apt. / building / etc.)', style: TextStyle(color: CupertinoColors.systemGrey3)),
              ],
            ),
            placeholder: '12 chars max',
            placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey3),
            maxLength: 12,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
              onTextChanged();
            },
            onEditingComplete: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onTextChanged();
            },
          )),
          if (!_showColorPicker)
            CupertinoListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Accent color'),
                  const SizedBox(width: 10),
                  _singleColorButton(widget.controller.sticker.data.accentColor ?? Colors.yellow, () {}),
                ],
              ),
              additionalInfo: const Text('more colors', style: TextStyle(color: CupertinoColors.systemGrey3)),
              trailing: const CupertinoListTileChevron(),
              onTap: () => setState(() => _showColorPicker = !_showColorPicker),
            ),
          if (_showColorPicker)
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: Colors.primaries
                    .map((c) => Padding(
                        padding: const EdgeInsets.all(5),
                        child: _singleColorButton(
                          c,
                          () => setState(() {
                            _showColorPicker = false;
                            widget.controller.set((data) => data.accentColor = c);
                          }),
                        )))
                    .toList(),
              ),
            ),
          CupertinoListTile(
              title: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Icon'),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    widget.controller.sticker.data.icon ?? CupertinoIcons.bell_fill,
                    color: (widget.controller.sticker.data.accentColor ?? Colors.yellow).shade600,
                  ),
                )
              ]),
              additionalInfo: const Text('more icons', style: TextStyle(color: CupertinoColors.systemGrey3)),
              trailing: const CupertinoListTileChevron(),
              onTap: onPickIconTap),
          CupertinoListTile(
              title: const Text('Layout'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(widget.controller.sticker.data.vertical ? 'vertical' : 'horizontal',
                        style: const TextStyle(color: CupertinoColors.systemGrey3))),
                CupertinoSwitch(
                    onChanged: (bool value) => widget.controller.set((settings) => settings.vertical = value),
                    value: widget.controller.sticker.data.vertical,
                    trackColor: CupertinoColors.activeGreen)
              ]))
        ]);
  }

  @override
  void dispose() {
    _aptNumberController.removeListener(onTextChanged);
    _aptNumberController.dispose();
    super.dispose();
  }

  onPickIconTap() async {
    IconData? iconData = await FlutterIconPicker.showIconPicker(
      context,
      iconPackModes: [IconPack.cupertino],
      adaptiveDialog: true,
      iconSize: 32,
      showSearchBar: false,
      iconColor: (widget.controller.sticker.data.accentColor ?? Colors.yellow).shade700,
    );

    if (iconData != null) setState(() => widget.controller.set((data) => data.icon = iconData));
  }

  void onTextChanged() {
    widget.controller.set((settings) => settings.apt = _aptNumberController.value.text.trim());
  }

  static Widget _singleColorButton(MaterialColor color, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: CupertinoColors.systemGrey3),
          color: color.shade500,
        ),
        width: 26,
        height: 26,
      ),
    );
  }
}
