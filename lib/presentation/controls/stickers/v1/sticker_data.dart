import 'package:flutter/material.dart';
import '../../../../model/sticker.dart';

class StickerV1Data extends StickerData {
  StickerV1Data(Map? data) : super(data ?? {'handler': 'sticker_v1', 'data': {}});

  String get apt => getOrDefault('apt', '');
  set apt(value) => set('apt', value);

  bool get vertical => getOrDefault('vertical', true)!;
  set vertical(value) => set('vertical', value);

  String? get icon => get('icon');
  set icon(value) => set('icon', value);

  MaterialColor? get accentColor => getOrDefault('accentColor', Colors.yellow);
  set accentColor(value) => set('accentColor', value);

  @override
  String? get displayName => get('apt');
}
