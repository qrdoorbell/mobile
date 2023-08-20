import '../model/sticker.dart';
import '../presentation/controls/stickers/sticker_edit_controller.dart';

abstract class StickerHandlerService<TData extends StickerData> {
  final String handler;
  final List<String> templateIds = [];

  bool canHandle(String handlerOrTemplateId) => handler == handlerOrTemplateId || templateIds.contains(handlerOrTemplateId);

  StickerHandlerService({required this.handler, List<String>? templateIds}) {
    if (templateIds != null) this.templateIds.addAll(templateIds);
  }

  StickerEditController<TData> createEditController(Map? data);

  TData? parseStickerData(Map? data);
}

class StickerHandlerFactory {
  static final List<StickerHandlerService> _handlers = [];

  StickerHandlerFactory._();

  static void register<T extends StickerHandlerService<TData>, TData extends StickerData>(T handler) {
    _handlers.add(handler);
  }

  static StickerHandlerService? getHandler(String handler) => _handlers.where((x) => x.canHandle(handler)).firstOrNull;

  static TData? parseStickerData<TData extends StickerData>(StickerInfo stickerInfo) {
    var handler = getHandler(stickerInfo.handler!) as StickerHandlerService<TData>?;
    if (handler == null) return null;

    return handler.parseStickerData(stickerInfo.dataSnapshot());
  }
}
