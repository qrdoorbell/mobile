import 'package:flutter/cupertino.dart';

import '../../../data.dart';

abstract class StickerEditController<TData extends StickerData> extends ChangeNotifier {
  final StickerInfo<TData> sticker;

  Widget? _previewWidget;
  Widget? _settingsWidget;

  Widget get previewWidget => _previewWidget ??= createPreviewWidget();
  Widget get settingsWidget => _settingsWidget ??= createSettingsWidget();

  bool get isSettingsChanged => sticker.data.isChanged;

  StickerEditController(this.sticker);

  @protected
  Widget createPreviewWidget();

  @protected
  Widget createSettingsWidget();

  void set(void Function(TData) updateFunc) {
    updateFunc(sticker.data);

    _previewWidget = null;
    _settingsWidget = null;

    notifyListeners();
  }
}
