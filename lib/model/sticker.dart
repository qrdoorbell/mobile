import 'dart:convert';

import '../services/sticker_handler_factory.dart';

class StickerTemplateInfo {
  final String templateId;
  final String name;
  final StickerInfo template;
  final bool enabled;
  final DateTime created;
  final String owner;

  StickerTemplateInfo({
    required this.templateId,
    required this.name,
    required this.template,
    required this.enabled,
    required this.created,
    required this.owner,
  });

  StickerTemplateInfo copyWith({
    String? templateId,
    String? name,
    StickerInfo? template,
    bool? enabled,
    DateTime? created,
    String? owner,
  }) {
    return StickerTemplateInfo(
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      template: template ?? this.template,
      enabled: enabled ?? this.enabled,
      created: created ?? this.created,
      owner: owner ?? this.owner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': templateId,
      'name': name,
      'template': template.raw,
      'enabled': enabled,
      'created': created.millisecondsSinceEpoch,
      'owner': owner,
    };
  }

  factory StickerTemplateInfo.fromMap(Map<String, dynamic> map) {
    return StickerTemplateInfo(
      templateId: map['id'] ?? '',
      name: map['name'] ?? '',
      template: StickerInfo(Map.from(map['template'])),
      enabled: map['enabled'] ?? false,
      created: DateTime.fromMillisecondsSinceEpoch(map['created']?.toInt() ?? DateTime.now().millisecondsSinceEpoch),
      owner: map['owner'] ?? '',
    );
  }

  factory StickerTemplateInfo.fromJson(String source) => StickerTemplateInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StickerTemplateInfo(id: $templateId, name: $name, template: $template, enabled: $enabled, created: $created, owner: $owner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerTemplateInfo &&
        other.templateId == templateId &&
        other.name == name &&
        other.template == template &&
        other.enabled == enabled &&
        other.created == created &&
        other.owner == owner;
  }

  @override
  int get hashCode => templateId.hashCode ^ name.hashCode ^ template.hashCode ^ enabled.hashCode ^ created.hashCode ^ owner.hashCode;
}

final class StickerInfo<TData extends StickerData> {
  final Map _info;
  late final TData data;

  String get doorbellId => _info['doorbellId'] ?? '';
  String get stickerId => _info['stickerId'] ?? '';
  String get handler => _info['handler'];
  DateTime get created => DateTime.fromMillisecondsSinceEpoch(_info['created']?.toInt() ?? DateTime.now().millisecondsSinceEpoch);
  DateTime? get updated => _info['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(_info['updated']?.toInt()) : null;

  String? get displayName => data.displayName;

  Map get raw => _info;

  StickerInfo(Map info) : _info = info {
    data = StickerHandlerFactory.getStickerData(this) as TData;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerInfo &&
        other.doorbellId == doorbellId &&
        other.stickerId == stickerId &&
        other.handler == handler &&
        other.created == created &&
        other.updated == updated &&
        other.data == data;
  }

  @override
  int get hashCode => doorbellId.hashCode ^ stickerId.hashCode ^ handler.hashCode ^ created.hashCode ^ updated.hashCode ^ data.hashCode;

  @override
  String toString() => 'StickerTemplate(doorbellId: $doorbellId, stickerId: $stickerId, handler: $handler, data: $data)';
}

abstract class StickerData {
  final Map _data;
  DateTime? _updated;
  bool _isChanged = false;

  String? get displayName => null;
  DateTime? get updated => _updated;
  bool get isChanged => _isChanged;

  StickerData(Map data) : _data = data;

  T? get<T>(String key) => _data[key] as T?;
  T getOrDefault<T>(String key, T defaultValue) => get(key) ?? defaultValue;

  void set(String key, dynamic value) {
    if (_data[key] != value) {
      _data[key] = value;
      _updated = DateTime.now();
      _isChanged = true;
    }
  }

  Map toMap() => _data;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other.hashCode == hashCode && other is StickerData; // && other._data.entries.every((e) => e.value == _data[e.key]);
  }

  @override
  int get hashCode => _data.values.reduce((value, element) => value.hashCode ^ element.hashCode);

  @override
  String toString() => 'StickerData(data: $_data)';
}
