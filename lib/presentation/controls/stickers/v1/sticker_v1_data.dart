import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/IconPack.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:logging/logging.dart';
import '../../../../model/sticker.dart';

class StickerV1Data extends StickerData {
  static final logger = Logger('StickerV1Data');

  static final defaultData = {'apt': '', 'vertical': true, 'icon': null, 'accentColor': Colors.yellow.shade600.value};

  MaterialColor? _accentColor;
  IconData? _iconData;
  bool _iconLoaded = false;

  StickerV1Data(Map data) : super(data);

  String get apt => getOrDefault('apt', '');
  set apt(value) => set('apt', value.trim());

  bool get vertical => getOrDefault('vertical', true)!;
  set vertical(value) => set('vertical', value);

  IconData? get icon {
    if (_iconData != null) return _iconData;

    if (!_iconLoaded) {
      _iconLoaded = true;

      var iconStr = get('icon');
      if (iconStr == null) return null;

      try {
        _iconData = deserializeIcon(jsonDecode(iconStr));
        return _iconData;
      } catch (e) {
        logger.warning('Cannot deserialize icon: error=$e');
      }
    }

    return _iconData;
  }

  set icon(IconData? value) {
    _iconData = value;
    _iconLoaded = true;

    if (value == null) {
      set('icon', null);
      return;
    }

    try {
      var iconData = serializeIcon(value, iconPack: IconPack.cupertino)?..['codePoint'] = value.codePoint;
      set('icon', jsonEncode(iconData));
    } catch (e) {
      logger.warning('Cannot serialize icon: error=$e');
      set('icon', null);
      _iconData = null;
    }
  }

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
