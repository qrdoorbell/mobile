import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

import '../../presentation/controls/doorbell_users_list.dart';

class DoorbellUsersScreen extends StatelessWidget {
  static final logger = Logger('DoorbellUsersScreen');

  final User user = FirebaseAuth.instance.currentUser!;
  final String doorbellId;

  DoorbellUsersScreen({
    super.key,
    required this.doorbellId,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: DoorbellUsersList(doorbellId: doorbellId));
  }
}
