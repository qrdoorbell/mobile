import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../data.dart';
import 'sticker_v1_horizontal.dart';
import 'sticker_v1_vertical.dart';

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

abstract class StickerTemplateWidget extends StatelessWidget {
  final StickerEditController controller;

  const StickerTemplateWidget({Key? key, required this.controller}) : super(key: key);
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

class StickerV1EditController extends BaseStickerEditController {
  final TextEditingController aptNumberController;

  StickerV1EditController._(super.settings, super.previewWidgetFactory, super.settingsWidgetFactory)
      : aptNumberController = TextEditingController(text: settings.get('apt', ''));

  factory StickerV1EditController.create(StickerTemplateData settings) {
    return StickerV1EditController._(
        settings,
        (controller) => controller.settings.data['vertical'] == false
            ? StickerV1Horizontal(controller: controller)
            : StickerV1Vertical(controller: controller),
        (controller) => CupertinoListSection(
              backgroundColor: CupertinoColors.white,
              additionalDividerMargin: 6,
              header: const Text(
                'SETTINGS',
                style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
              ),
              children: [
                CupertinoListTile(
                    title: CupertinoTextField(
                  controller: (controller as StickerV1EditController).aptNumberController,
                  decoration: const BoxDecoration(),
                  textAlign: TextAlign.right,
                  prefix: const Text('Apartment / House'),
                  placeholder: 'number / code',
                  maxLength: 4,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  onEditingComplete: () => controller.setValue('apt', controller.aptNumberController.text),
                  onTapOutside: (event) => controller.setValue('apt', controller.aptNumberController.text),
                )),
                CupertinoListTile(
                    title: const Text('Vertical layout'),
                    trailing: CupertinoSwitch(
                      onChanged: (bool value) => controller.setValue('vertical', value),
                      value: controller.getValue('vertical', defaultValue: true)!,
                    )),
              ],
            ));
  }
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
