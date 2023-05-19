import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:nanoid/nanoid.dart';
import 'package:qrdoorbell_mobile/data.dart';

class InviteService extends ChangeNotifier {
  static final logger = Logger('InviteService');

  static Future<String> accept(String inviteId) async {
    logger.info("Proceed with invitation: id='$inviteId'");
    var data = await FirebaseDatabase.instance.ref('invites/$inviteId').get();
    var invite = Invite.fromMap(data.value as Map);
    if (invite.status != 'created') throw ArgumentError(invite.status, 'Invalid invite status');

    var now = DateTime.now();
    if (invite.expires.isAfter(now)) {
      var uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw AssertionError('User is not logged in');

      logger.info("Accepted invitation: id='$inviteId', doorbellId='${invite.doorbellId}'");

      await FirebaseDatabase.instance
          .ref('doorbell-users/${invite.doorbellId}/$uid')
          .set({'role': invite.role, 'created': now.millisecondsSinceEpoch, 'inviteId': invite.id});

      await FirebaseDatabase.instance
          .ref('invites/$inviteId')
          .update({'status': 'accepted', 'updated': now.millisecondsSinceEpoch, 'uid': uid});

      return invite.doorbellId;
    } else {
      await FirebaseDatabase.instance.ref('invites/$inviteId').update({'status': 'expired', 'updated': now.millisecondsSinceEpoch});
      throw ArgumentError(invite.expires, 'Invite already expired');
    }
  }

  static Invite createInvite(String doorbellId, [String role = 'participant']) {
    return Invite(
        id: nanoid(10),
        doorbellId: doorbellId,
        created: DateTime.now(),
        expires: DateTime.now().add(const Duration(days: 7)),
        owner: FirebaseAuth.instance.currentUser!.uid,
        role: role,
        status: 'created',
        updated: null,
        uid: null);
  }

  static Future saveInvite(Invite invite) async {
    await FirebaseDatabase.instance.ref('invites/${invite.id}').set(invite.toMap());
  }
}
