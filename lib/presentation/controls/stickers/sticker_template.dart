import 'package:flutter/cupertino.dart';

import '../../../data.dart';

abstract class StickerEditController<TData extends StickerTemplateData> extends ChangeNotifier {
  final TData _settings;

  Widget? _previewWidget;
  Widget? _settingsWidget;

  Widget get previewWidget => _previewWidget ??= createPreviewWidget();
  Widget get settingsWidget => _settingsWidget ??= createSettingsWidget();

  TData get settings => _settings;

  StickerEditController(TData settings) : _settings = settings;

  @protected
  Widget createPreviewWidget();

  @protected
  Widget createSettingsWidget();

  @protected
  void updateSettings(void Function(Map data) updateFunc) {
    updateFunc(_settings.data);

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

class StickersService {
  static final StickersService _instance = StickersService._();

  final Map<String, StickerEditController Function(StickerTemplateData?)> _controllerFactories = {};

  factory StickersService() => _instance;

  StickersService._();

  StickersService register<T extends StickerEditController>(String stickerTemplateId, T Function(StickerTemplateData?) controllerFactory) {
    _controllerFactories[stickerTemplateId] = controllerFactory;
    return this;
  }

  T create<T extends StickerEditController>(String stickerTemplateId, {StickerTemplateData? settings}) {
    if (_controllerFactories.containsKey(stickerTemplateId)) {
      return _controllerFactories[stickerTemplateId]?.call(settings) as T;
    }

    throw Exception("Unknown sticker template id: $stickerTemplateId");
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
