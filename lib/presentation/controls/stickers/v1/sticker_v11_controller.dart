import 'package:flutter/material.dart';

import '../../../../services/sticker_handler_factory.dart';
import '../sticker_edit_controller.dart';
import 'sticker_v1_data.dart';
import 'sticker_v1_service.dart';
import 'sticker_v11_preview.dart';
import 'sticker_v11_settings_widget.dart';

class StickerV11Controller extends StickerEditController<StickerV1Data> {
  bool _isEditingText = false;
  bool _isColorPickerVisible = false;
  bool _isIconPickerVisible = false;

  final FocusNode aptTextFocusNode = FocusNode(canRequestFocus: true);

  @override
  StickerV11Preview get previewWidget => super.previewWidget as StickerV11Preview;

  @override
  StickerV11SettingsWidget get settingsWidget => super.settingsWidget as StickerV11SettingsWidget;

  StickerV11Controller(super.sticker);

  bool get isEditingText => _isEditingText;
  set isEditingText(bool value) {
    _isEditingText = value;
    notifyListeners();
  }

  bool get isColorPickerVisible => _isColorPickerVisible;
  set isColorPickerVisible(bool value) {
    _isColorPickerVisible = value;
    notifyListeners();
  }

  bool get isIconPickerVisible => _isIconPickerVisible;
  set isIconPickerVisible(bool value) {
    _isIconPickerVisible = value;
    notifyListeners();
  }

  void resetFlags() {
    _isEditingText = false;
    _isIconPickerVisible = false;
  }

  @override
  StickerV11Preview createPreviewWidget() => StickerV11Preview.create(controller: this);

  @override
  StickerV11SettingsWidget createSettingsWidget() => StickerV11SettingsWidget(controller: this);

  static void register() {
    StickerHandlerFactory.register<StickerV1Service, StickerV1Data>(StickerV1Service());
  }
}
