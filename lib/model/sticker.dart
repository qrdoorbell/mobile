import 'dart:convert';

class StickerTemplateInfo {
  final String id;
  final String name;
  final StickerTemplate template;
  final bool enabled;
  final DateTime created;
  final String owner;

  StickerTemplateInfo({
    required this.id,
    required this.name,
    required this.template,
    required this.enabled,
    required this.created,
    required this.owner,
  });

  StickerTemplateInfo copyWith({
    String? id,
    String? name,
    StickerTemplate? template,
    bool? enabled,
    DateTime? created,
    String? owner,
  }) {
    return StickerTemplateInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      template: template ?? this.template,
      enabled: enabled ?? this.enabled,
      created: created ?? this.created,
      owner: owner ?? this.owner,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'template': template.toMap(),
      'enabled': enabled,
      'created': created.millisecondsSinceEpoch,
      'owner': owner,
    };
  }

  factory StickerTemplateInfo.fromMap(Map<String, dynamic> map) {
    return StickerTemplateInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      template: StickerTemplate.fromMap(Map.from(map['template'])),
      enabled: map['enabled'] ?? false,
      created: DateTime.fromMillisecondsSinceEpoch(map['created']?.toInt() ?? DateTime.now().millisecondsSinceEpoch),
      owner: map['owner'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory StickerTemplateInfo.fromJson(String source) => StickerTemplateInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StickerTemplateInfo(id: $id, name: $name, template: $template, enabled: $enabled, created: $created, owner: $owner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerTemplateInfo &&
        other.id == id &&
        other.name == name &&
        other.template == template &&
        other.enabled == enabled &&
        other.created == created &&
        other.owner == owner;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ template.hashCode ^ enabled.hashCode ^ created.hashCode ^ owner.hashCode;
  }
}

class StickerTemplate {
  final String handler;
  final Map data;
  final Map params;
  StickerTemplate({
    required this.handler,
    required this.data,
    required this.params,
  });

  StickerTemplate copyWith({
    String? handler,
    Map? data,
    Map? params,
  }) {
    return StickerTemplate(
      handler: handler ?? this.handler,
      data: data ?? this.data,
      params: params ?? this.params,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'handler': handler,
      'data': data,
      'params': params,
    };
  }

  factory StickerTemplate.fromMap(Map<String, dynamic> map) {
    return StickerTemplate(
      handler: map['handler'] ?? '',
      data: map['data'] != null ? Map.from(map['data']) : {},
      params: map['params'] != null ? Map.from(map['params']) : {},
    );
  }

  String toJson() => json.encode(toMap());

  factory StickerTemplate.fromJson(String source) => StickerTemplate.fromMap(json.decode(source));

  @override
  String toString() => 'StickerTemplate(handler: $handler, data: $data, params: $params)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerTemplate && other.handler == handler && other.data == data && other.params == params;
  }

  @override
  int get hashCode => handler.hashCode ^ data.hashCode ^ params.hashCode;
}

class DoorbellSticker {
  final String stickerId;
  final DateTime created;
  final StickerTemplate template;
  final Map params;
  final String? lang;
  final String? pageTitle;
  final String? pageText;
  final String? pageButtonText;

  DoorbellSticker({
    required this.stickerId,
    required this.created,
    required this.template,
    required this.params,
    this.lang,
    this.pageTitle,
    this.pageText,
    this.pageButtonText,
  });

  DoorbellSticker copyWith({
    String? stickerId,
    DateTime? created,
    StickerTemplate? template,
    Map? params,
    String? lang,
    String? pageTitle,
    String? pageText,
    String? pageButtonText,
  }) {
    return DoorbellSticker(
      stickerId: stickerId ?? this.stickerId,
      created: created ?? this.created,
      template: template ?? this.template,
      params: params ?? this.params,
      lang: lang ?? this.lang,
      pageTitle: pageTitle ?? this.pageTitle,
      pageText: pageText ?? this.pageText,
      pageButtonText: pageButtonText ?? this.pageButtonText,
    );
  }

  Map toMap() {
    return {
      'id': stickerId,
      'created': created.millisecondsSinceEpoch,
      'template': template.toMap(),
      'params': params,
      'lang': lang,
      'pageTitle': pageTitle,
      'pageText': pageText,
      'pageButtonText': pageButtonText,
    };
  }

  factory DoorbellSticker.fromMapAndId(String stickerId, Map map) {
    return DoorbellSticker(
      stickerId: stickerId,
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      template: StickerTemplate.fromMap(Map.from(map['template'])),
      params: map['params'] != null ? Map.from(map['params']) : {},
      lang: map['lang'],
      pageTitle: map['pageTitle'],
      pageText: map['pageText'],
      pageButtonText: map['pageButtonText'],
    );
  }

  factory DoorbellSticker.fromMap(Map map) {
    return DoorbellSticker(
      stickerId: map['id'],
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      template: StickerTemplate.fromMap(Map.from(map['template'])),
      params: map['params'] != null ? Map.from(map['params']) : {},
      lang: map['lang'],
      pageTitle: map['pageTitle'],
      pageText: map['pageText'],
      pageButtonText: map['pageButtonText'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DoorbellSticker.fromJson(String source) => DoorbellSticker.fromMap(json.decode(source));

  @override
  String toString() => 'DoorbellSticker(stickerId: $stickerId, created: $created, template: $template, params: $params)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DoorbellSticker && other.created == created && other.template == template && other.params == params;
  }

  @override
  int get hashCode => stickerId.hashCode ^ created.hashCode ^ template.hashCode ^ params.hashCode;
}
