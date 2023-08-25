import 'dart:convert';
import 'dart:typed_data';

import '../app_options.dart';
import '../data.dart';
import '../model/sticker.dart';
import '../tools.dart';
import 'sticker_handler_factory.dart';

class StickerService {
  static final StickerService _instance = StickerService._internal();

  factory StickerService() => _instance;

  StickerService._internal();

  Future<List<StickerTemplateInfo>> getStickerTemplates() async {
    var response = await HttpUtils.secureGet(Uri.parse('${AppSettings.apiUrl}/api/v1/sticker-templates'));

    if (response.statusCode != 200) throw Exception('ERROR: unable to get sticker templates: responseCode=${response.statusCode}');

    var templates = <StickerTemplateInfo>[];
    for (var template in jsonDecode(response.body)) {
      templates.add(StickerTemplateInfo.fromMap(template));
    }

    return templates;
  }

  Future<StickerInfo?> createSticker(String handler, String? templateId, String doorbellId, Map data) async {
    var response = await HttpUtils.securePost(Uri.parse('${AppSettings.apiUrl}/api/v1/doorbells/$doorbellId/stickers'),
        body: jsonEncode({'handler': handler, 'templateId': templateId, 'data': data}));

    if (response.statusCode != 200) throw Exception('ERROR: unable to create sticker: responseCode=${response.statusCode}');
    return StickerHandlerFactory.createStickerInfo(jsonDecode(response.body));
  }

  Future<void> updateSticker(StickerInfo stickerInfo) async {
    var response = await HttpUtils.securePut(
        Uri.parse('${AppSettings.apiUrl}/api/v1/doorbells/${stickerInfo.doorbellId}/stickers/${stickerInfo.stickerId}'),
        body: jsonEncode({'data': stickerInfo.data.toMap()}));

    if (response.statusCode != 200) throw Exception('ERROR: unable to update sticker: responseCode=${response.statusCode}');

    stickerInfo.data.acceptChanges();
  }

  Future<void> deleteSticker(StickerInfo stickerInfo) async {
    var response = await HttpUtils.secureDelete(
        Uri.parse('${AppSettings.apiUrl}/api/v1/doorbells/${stickerInfo.doorbellId}/stickers/${stickerInfo.stickerId}'));

    if (response.statusCode != 200) throw Exception('ERROR: unable to delete sticker: responseCode=${response.statusCode}');
  }

  Future<Uint8List> getStickerImage(String doorbellId, String stickerId, [bool preview = false]) async {
    var response = await HttpUtils.secureGet(
        Uri.parse('${AppSettings.apiUrl}/api/v1/doorbells/$doorbellId/stickers/$stickerId/print${preview ? '?preview=true' : ''}'));

    if (response.statusCode != 200) throw Exception('ERROR: unable to download image: responseCode=${response.statusCode}');
    return response.bodyBytes;
  }

  Future<Uint8List> getStickerPdf(String doorbellId, String stickerId) async {
    var response =
        await HttpUtils.secureGet(Uri.parse('${AppSettings.apiUrl}/api/v1/doorbells/$doorbellId/stickers/$stickerId/print?pdf=true'));

    if (response.statusCode != 200) throw Exception('ERROR: unable to download PDF: responseCode=${response.statusCode}');
    return response.bodyBytes;
  }
}
