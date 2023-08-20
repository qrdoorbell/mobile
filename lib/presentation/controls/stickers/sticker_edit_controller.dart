import 'package:flutter/cupertino.dart';

import '../../../data.dart';

abstract class StickerEditController<TData extends StickerData> extends ChangeNotifier {
  late final StickerInfo _stickerInfo;
  late final TData _stickerData;

  Widget? _previewWidget;
  Widget? _settingsWidget;

  Widget get previewWidget => _previewWidget ??= createPreviewWidget();
  Widget get settingsWidget => _settingsWidget ??= createSettingsWidget();

  TData get settings => _stickerData;
  bool get isSettingsChanged => true;

  StickerEditController(StickerInfo info) : _stickerInfo = info {
    _stickerData = createStickerData(info.dataSnapshot());
  }

  StickerInfo get stickerInfo => StickerInfo({..._stickerInfo.toMap(), 'data': _stickerData.toMap()});

  @protected
  TData createStickerData(Map? data);

  @protected
  Widget createPreviewWidget();

  @protected
  Widget createSettingsWidget();

  @protected
  void updateSettings(void Function(TData data) updateFunc) {
    updateFunc(settings);

    _previewWidget = null;
    _settingsWidget = null;

    notifyListeners();
  }

  void set(void Function(TData) updateFunc) {
    updateFunc(_stickerData);

    _previewWidget = null;
    _settingsWidget = null;

    notifyListeners();
  }
}
