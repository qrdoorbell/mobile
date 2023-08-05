import 'package:flutter/cupertino.dart';

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
  StickerV1EditController._(super.settings, super.previewWidgetFactory, super.settingsWidgetFactory);

  factory StickerV1EditController.create(StickerTemplateData settings) {
    var displayNameController = TextEditingController(text: aptNumberController);

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
                    title: const Text('Vertical orientation'),
                    trailing: CupertinoSwitch(
                      onChanged: (bool value) => controller.setValue('vertical', value),
                      value: controller.getValue('vertical', true),
                    )),
                CupertinoListTile(
                    title: const Text('APT. number'),
                    trailing: CupertinoTextField(
                      controller: displayNameController,
                      prefix: const Text('####'),
                      decoration: const BoxDecoration(),
                      textAlign: TextAlign.right,
                      onTapOutside: (event) async {
                        if (userName != displayNameController.text) {
                          await RouteStateScope.of(context)
                              .wait(DataStore.of(context).updateUserDisplayName(displayNameController.text), destinationRoute: "/profile");
                        }
                      },
                      onChanged: (value) => controller.setValue('apt', value),
                    )),
              ],
            ));
  }

  static 
}

class StickerEditControllers {
  StickerEditControllers._();

  static StickerEditController create(String stickerTemplateId, {StickerTemplateData? settings}) {
    return StickerV1EditController.create(settings ?? StickerTemplateData(handler: stickerTemplateId, data: {}, params: {}));
    // switch (stickerTemplateId) {
    //   case 'v1_vertical':
    //     return StickerV1EditController.create(settings);
    //   case 'v1_horizontal':
    //     return StickerV1Horizontal();
    //   default:
    //     return StickerV1Vertical();
    // }
  }
}

extension StickerEditControllerExtension on StickerEditController {
  StickerEditController setValue<T>(String key, T value) {
    updateSettings((data) => data[key] = value);
    return this;
  }

  T getValue<T>(String key, T defaultValue) {
    return settings.get(key, defaultValue);
  }
}
