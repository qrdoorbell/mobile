import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../../../model/sticker.dart';

class StickerV1Data extends StickerData {
  static final defaultData = {'apt': '', 'vertical': true, 'icon': null, 'accentColor': Colors.yellow.value};

  MaterialColor? _accentColor;

  StickerV1Data(Map data) : super(data);

  String get apt => getOrDefault('apt', '');
  set apt(value) => set('apt', value.trim());

  bool get vertical => getOrDefault('vertical', true)!;
  set vertical(value) => set('vertical', value);

  String? get icon => get('icon');
  set icon(value) => set('icon', value);

  MaterialColor? get accentColor {
    if (_accentColor != null) return _accentColor;

    int? color = get('accentColor');
    if (color == null) return null;

    _accentColor ??= Colors.primaries.firstWhereOrNull((c) => c.value == color);
    return _accentColor;
  }

  set accentColor(MaterialColor? color) {
    set('accentColor', color?.value);
    _accentColor = color;
  }

  @override
  String? get displayName => get('apt');
}
