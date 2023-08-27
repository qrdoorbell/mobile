import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'sticker_v11_controller.dart';

class StickerV11SettingsWidget extends StatefulWidget {
  final StickerV11Controller controller;

  const StickerV11SettingsWidget({super.key, required this.controller});

  @override
  State<StickerV11SettingsWidget> createState() => _StickerV11SettingsWidgetState();
}

class _StickerV11SettingsWidgetState extends State<StickerV11SettingsWidget> {
  final _aptNumberController = TextEditingController();

  MaterialColor get accentColor => widget.controller.sticker.data.accentColor ?? Colors.yellow;

  @override
  void initState() {
    super.initState();
    _aptNumberController.text = widget.controller.sticker.data.apt;
    _aptNumberController.addListener(onTextChanged);
    widget.controller.addListener(onControllerDataChanged);
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
            focusNode: widget.controller.aptTextFocusNode,
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
          if (!widget.controller.isColorPickerVisible)
            CupertinoListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Accent color'),
                  const SizedBox(width: 10),
                  _singleColorButton(accentColor, () => setState(() => widget.controller.isColorPickerVisible = true)),
                ],
              ),
              additionalInfo: const Text('more colors', style: TextStyle(color: CupertinoColors.systemGrey3)),
              trailing: const CupertinoListTileChevron(),
              onTap: () => setState(() => widget.controller.isColorPickerVisible = true),
            ),
          if (widget.controller.isColorPickerVisible)
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: Colors.primaries
                    .where((c) => c != accentColor)
                    .map((c) => Padding(
                        padding: const EdgeInsets.all(5),
                        child: _singleColorButton(
                          c,
                          () => setState(() {
                            widget.controller.isColorPickerVisible = false;
                            widget.controller.set((data) => data.accentColor = c);
                          }),
                        )))
                    .toList()
                  ..insertAll(0, [
                    Padding(
                        padding: const EdgeInsets.only(top: 3, bottom: 5, left: 0, right: 0),
                        child: IconButton(
                          alignment: Alignment.topLeft,
                          onPressed: () => setState(() => widget.controller.isColorPickerVisible = false),
                          icon: const Icon(CupertinoIcons.chevron_back, color: CupertinoColors.systemGrey3),
                        )),
                    Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 20),
                        child: _singleColorButton(accentColor, () => setState(() => widget.controller.isColorPickerVisible = false))),
                  ]),
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
                    color: accentColor.shade600,
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
    widget.controller.removeListener(onControllerDataChanged);
    _aptNumberController.removeListener(onTextChanged);
    _aptNumberController.dispose();
    super.dispose();
  }

  onPickIconTap() async {
    IconData? iconData = await FlutterIconPicker.showIconPicker(
      context,
      iconPackModes: [IconPack.cupertino],
      adaptiveDialog: true,
      iconSize: 42,
      showSearchBar: false,
      iconColor: accentColor.shade700,
      selectedIcon: widget.controller.sticker.data.icon,
    );

    if (iconData != null) setState(() => widget.controller.set((data) => data.icon = iconData));
  }

  void onControllerDataChanged() {
    if (widget.controller.isEditingText)
      widget.controller.aptTextFocusNode.requestFocus();
    else if (widget.controller.isIconPickerVisible) onPickIconTap();

    widget.controller.resetFlags();
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
