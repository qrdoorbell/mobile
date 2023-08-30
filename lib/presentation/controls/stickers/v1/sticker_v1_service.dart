import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../services/sticker_handler_factory.dart';
import '../../../../model/sticker.dart';
import '../sticker_edit_controller.dart';
import 'sticker_v1_data.dart';
import 'sticker_v1_icon.dart';
import 'sticker_v11_controller.dart';

class StickerV1Service extends StickerHandlerService<StickerV1Data> {
  StickerV1Service() : super(handler: 'sticker_v1', templateIds: ['sticker_v1_vertical', 'sticker_v1_horizontal']);

  @override
  StickerV1Data getStickerData(StickerInfo sticker) {
    sticker.raw['data'] ??= StickerV1Data.defaultData;
    return StickerV1Data(sticker.raw['data']);
  }

  @override
  StickerEditController<StickerV1Data> createEditController(StickerInfo<StickerV1Data>? sticker) =>
      StickerV11Controller(sticker ?? StickerInfo<StickerV1Data>({'handler': 'sticker_v1', 'data': StickerV1Data.defaultData}));

  @override
  Widget getStickerIconWidget(StickerInfo sticker, void Function()? onPressed) =>
      StickerV1Icon(stickerData: sticker.data as StickerV1Data, onPressed: onPressed);

  @override
  StickerInfo<StickerV1Data> createStickerInfo(Map data) => StickerInfo<StickerV1Data>(data);
}
