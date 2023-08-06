import 'package:flutter/cupertino.dart';

import '../../../data.dart';
import 'sticker_v1.dart';

abstract class StickerEditController extends ChangeNotifier {
  StickerTemplateData _settings;
  Widget? _previewWidget;
  Widget? _settingsWidget;

  Widget get previewWidget => _previewWidget ??= createPreviewWidget();
  Widget get settingsWidget => _settingsWidget ??= createSettingsWidget();

  StickerTemplateData get settings => _settings;

  StickerEditController(StickerTemplateData settings) : _settings = settings;

  @protected
  Widget createPreviewWidget();

  @protected
  Widget createSettingsWidget();

  @protected
  void updateSettings(void Function(Map data) updateFunc) {
    final newSettings = _settings.copyWith();
    updateFunc(newSettings.data);

    _settings = newSettings;
    _previewWidget = null;
    _settingsWidget = null;

    notifyListeners();
  }
}

class BaseStickerEditController extends StickerEditController {
  @protected
  Widget Function(StickerEditController) previewWidgetFactory;
  @protected
  Widget Function(StickerEditController) settingsWidgetFactory;

  BaseStickerEditController(super.settings, this.previewWidgetFactory, this.settingsWidgetFactory);

  @override
  Widget createPreviewWidget() => previewWidgetFactory(this);

  @override
  Widget createSettingsWidget() => settingsWidgetFactory(this);
}

class StickerEditControllers {
  StickerEditControllers._();

  static StickerEditController create(String stickerTemplateId, {StickerTemplateData? settings}) {
    return StickerV1EditController.create(settings ?? StickerTemplateData(handler: stickerTemplateId, data: {}, params: {}));
  }
}

extension StickerEditControllerExtension on StickerEditController {
  StickerEditController setValue<T>(String key, T? value) {
    if (getValue(key) != value) {
      updateSettings((data) => data[key] = value);
    }

    return this;
  }

  T? getValue<T>(String key, {T? defaultValue}) {
    return settings.get(key, defaultValue);
  }
}
