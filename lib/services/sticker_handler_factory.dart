import 'package:flutter/cupertino.dart';

import '../model/sticker.dart';
import '../presentation/controls/stickers/sticker_edit_controller.dart';

abstract class StickerHandlerService<TData extends StickerData> {
  final String handler;
  final List<String> templateIds = [];

  bool canHandle(String handlerOrTemplateId) => handler == handlerOrTemplateId || templateIds.contains(handlerOrTemplateId);

  StickerHandlerService({required this.handler, List<String>? templateIds}) {
    if (templateIds != null) this.templateIds.addAll(templateIds);
  }

  StickerEditController<TData> createEditController(StickerInfo<TData>? sticker);
  StickerInfo<TData> createStickerInfo(Map data);
  TData getStickerData(StickerInfo sticker);
  Widget getStickerIconWidget(StickerInfo sticker, void Function()? onPressed);
}

class StickerHandlerFactory {
  static final List<StickerHandlerService> _handlers = [];

  StickerHandlerFactory._();

  static void register<T extends StickerHandlerService<TData>, TData extends StickerData>(T handler) {
    _handlers.add(handler);
  }

  static StickerInfo? createStickerInfo(Map data) {
    var handler = _getStickerHandlerService(data['handler']);
    if (handler == null) return null;

    return handler.createStickerInfo(data);
  }

  static Widget getStickerIconWidget(StickerInfo sticker, void Function()? onPressed) {
    var handler = _getStickerHandlerService(sticker.handler);
    if (handler == null) throw Exception('Sticker handler not found: ${sticker.handler}');

    return handler.getStickerIconWidget(sticker, onPressed);
  }

  static StickerEditController createEditController(String handler, StickerInfo? stickerInfo) {
    var svc = _getStickerHandlerService(handler);
    if (svc == null) throw Exception('Sticker handler not found: $handler');

    return svc.createEditController(stickerInfo);
  }

  static StickerData getStickerData(StickerInfo sticker) {
    var handler = _getStickerHandlerService(sticker.handler);
    if (handler == null) throw Exception('Sticker handler not found: ${sticker.handler}');

    return handler.getStickerData(sticker);
  }

  static StickerHandlerService? _getStickerHandlerService(String handler) => _handlers.where((x) => x.canHandle(handler)).firstOrNull;
}
