import 'package:flutter/cupertino.dart';

import '../../../data.dart';

abstract class StickerEditController<TData extends StickerData> extends ChangeNotifier {
  late final StickerInfo _stickerInfo;
  late final TData _stickerData;
  bool _isSettingsChanged = false;

  Widget? _previewWidget;
  Widget? _settingsWidget;

  Widget get previewWidget => _previewWidget ??= createPreviewWidget();
  Widget get settingsWidget => _settingsWidget ??= createSettingsWidget();

  TData get settings => _stickerData;
  bool get isSettingsChanged => _isSettingsChanged;

  StickerEditController(StickerInfo info) : _stickerInfo = info {
    _stickerData = createStickerData(info.dataSnapshot());
  }

  StickerInfo get stickerInfo {
    var info = _stickerInfo.toMap();
    info['data'] = _stickerData.toMap();
    info['displayName'] = _stickerData.displayName;

    return StickerInfo(info);
  }

  @protected
  TData createStickerData(Map? data);

  @protected
  Widget createPreviewWidget();

  @protected
  Widget createSettingsWidget();

  @protected
  void updateSettings(void Function(TData data) updateFunc) {
    updateFunc(settings);

    _isSettingsChanged = true;
    _previewWidget = null;
    _settingsWidget = null;

    notifyListeners();
  }

  void set(void Function(TData) updateFunc) {
    updateFunc(_stickerData);

    _isSettingsChanged = true;
    _previewWidget = null;
    _settingsWidget = null;

    notifyListeners();
  }
}
