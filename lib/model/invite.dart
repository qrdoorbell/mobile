import 'dart:convert';

class Invite {
  final String id;
  final String doorbellId;
  final String role;
  final String status;
  final DateTime expires;
  final DateTime created;
  final DateTime? updated;
  final String owner;
  final String? uid;

  Invite({
    required this.id,
    required this.doorbellId,
    required this.role,
    required this.status,
    required this.expires,
    required this.created,
    required this.updated,
    required this.owner,
    required this.uid,
  });

  Invite copyWith({
    String? id,
    String? doorbellId,
    String? role,
    String? status,
    DateTime? expires,
    DateTime? created,
    DateTime? updated,
    String? owner,
    String? uid,
  }) {
    return Invite(
      id: id ?? this.id,
      doorbellId: doorbellId ?? this.doorbellId,
      role: role ?? this.role,
      status: status ?? this.status,
      expires: expires ?? this.expires,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      owner: owner ?? this.owner,
      uid: uid ?? this.uid,
    );
  }

  Map toMap() {
    return {
      'id': id,
      'doorbell': doorbellId,
      'role': role,
      'status': status,
      'expires': expires.millisecondsSinceEpoch,
      'created': created.millisecondsSinceEpoch,
      'updated': updated?.millisecondsSinceEpoch,
      'owner': owner,
      'uid': uid,
    };
  }

  factory Invite.fromMap(Map map) {
    return Invite(
      id: map['id'] ?? '',
      doorbellId: map['doorbell'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? '',
      expires: DateTime.fromMillisecondsSinceEpoch(map['expires']?.toInt() ?? 0),
      created: DateTime.fromMillisecondsSinceEpoch(map['created']?.toInt() ?? 0),
      updated: map['updated'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updated']?.toInt()) : null,
      owner: map['owner'] ?? '',
      uid: map['uid'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Invite.fromJson(String source) => Invite.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Invite(id: $id, doorbell: $doorbellId, role: $role, status: $status, expires: $expires, created: $created, updated: $updated, uid: $uid, owner: $owner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Invite &&
        other.id == id &&
        other.doorbellId == doorbellId &&
        other.role == role &&
        other.status == status &&
        other.expires == expires &&
        other.created == created &&
        other.updated == updated &&
        other.uid == uid &&
        other.owner == owner;
  }

  @override
  int get hashCode {
    return id.hashCode ^ doorbellId.hashCode ^ role.hashCode ^ status.hashCode ^ expires.hashCode ^ created.hashCode ^ owner.hashCode;
  }
}
