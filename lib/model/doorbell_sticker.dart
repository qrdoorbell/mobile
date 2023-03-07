import 'dart:convert';

class DoorbellSticker {
  final String stickerId;
  final DateTime created;
  final StickerTemplate template;
  final Map params;
  DoorbellSticker({
    required this.stickerId,
    required this.created,
    required this.template,
    required this.params,
  });

  DoorbellSticker copyWith({
    String? stickerId,
    DateTime? created,
    StickerTemplate? template,
    Map? params,
  }) {
    return DoorbellSticker(
      stickerId: stickerId ?? this.stickerId,
      created: created ?? this.created,
      template: template ?? this.template,
      params: params ?? this.params,
    );
  }

  Map toMap() {
    return {
      'id': stickerId,
      'created': created.millisecondsSinceEpoch,
      'template': template.toMap(),
      'params': params,
    };
  }

  factory DoorbellSticker.fromMapAndId(String stickerId, Map map) {
    return DoorbellSticker(
      stickerId: stickerId,
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      template: StickerTemplate.fromMap(map['template']),
      params: map['params'],
    );
  }

  factory DoorbellSticker.fromMap(Map map) {
    return DoorbellSticker(
      stickerId: map['id'],
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      template: StickerTemplate.fromMap(map['template']),
      params: map['params'],
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

class StickerTemplate {
  final String id;
  final String handler;
  final Map data;
  StickerTemplate({
    required this.id,
    required this.handler,
    required this.data,
  });

  StickerTemplate copyWith({
    String? id,
    String? handler,
    Map? data,
  }) {
    return StickerTemplate(
      id: id ?? this.id,
      handler: handler ?? this.handler,
      data: data ?? this.data,
    );
  }

  Map toMap() {
    return {
      'id': id,
      'handler': handler,
      'data': data,
    };
  }

  factory StickerTemplate.fromMap(Map map) {
    return StickerTemplate(
      id: map['id'] ?? '',
      handler: map['handler'] ?? '',
      data: map['data'],
    );
  }

  String toJson() => json.encode(toMap());

  factory StickerTemplate.fromJson(String source) => StickerTemplate.fromMap(json.decode(source));

  @override
  String toString() => 'Template(id: $id, handler: $handler, data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StickerTemplate && other.id == id && other.handler == handler && other.data == data;
  }

  @override
  int get hashCode => id.hashCode ^ handler.hashCode ^ data.hashCode;
}
