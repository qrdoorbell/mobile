import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:qrdoorbell_mobile/presentation/screens/privacy_policy_screen.dart';

import '../../app_options.dart';
import '../../routing/route_state.dart';
import '../../tools.dart';

class ProfileDeleteScreen extends StatelessWidget {
  static final logger = Logger('ProfileDeleteScreen');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.destructiveRed,
          middle: const Text("Delete account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: CupertinoColors.white)),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => RouteStateScope.of(context).go("/profile"),
            color: CupertinoColors.black,
            previousPageTitle: "Profile",
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('IRREVERSIBLE ACTION WARNING!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                )),
            const Padding(padding: EdgeInsets.only(top: 20)),
            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              const Text(
                'This will permanently delete all your account data:\n    - user profile,\n    - user settings,\n    - doorbell assignments,\n    - doorbell events history data.',
                style: TextStyle(fontSize: 16),
              ),
              const Padding(padding: EdgeInsets.only(top: 40)),
              const Text(
                'ONCE YOUR ACCOUNT IS DELETED, IT CANNOT BE RESTORED!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Padding(padding: EdgeInsets.all(15)),
              CupertinoButton(
                color: CupertinoColors.destructiveRed,
                child: const Text('CONFIRM DELETE', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  await _showDeleteConfirmationDialog(context);
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 15)),
              Center(
                child: TextButton(
                  child: const Text('Privacy Policy', style: TextStyle(fontSize: 16, color: CupertinoColors.link)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
                  },
                ),
              ),
            ]),
          ]),
        ));
  }

  Future<void> _deleteAccount(BuildContext context) async {
    var router = RouteStateScope.of(context);
    var resp = await HttpUtils.securePost(Uri.parse('$QRDOORBELL_API_URL/user/profile/delete'));
    if (resp.statusCode != 200) {
      logger.warning('Failed to delete account!\n\n${resp.body}');
      throw AssertionError('Failed to delete account!\n\n${resp.body}');
    }

    router.go('/logout');
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Confirm delete account!"),
          content: const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                  "Are you sure you want to delete you account profile?\n\nThis cannot be undone and all associated data will be lost.")),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.bold, fontSize: 17),
              ),
              onPressed: () async {
                await RouteStateScope.of(context).wait(_deleteAccount(context), destinationRouteFunc: (_) => '/logout');
              },
            ),
          ],
        );
      },
    );
  }
}
