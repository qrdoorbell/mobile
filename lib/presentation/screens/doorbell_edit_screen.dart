import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/routing.dart';

import '../../data.dart';

class DoorbellEditScreen extends StatefulWidget {
  final String doorbellId;

  const DoorbellEditScreen({super.key, required this.doorbellId});

  @override
  State<DoorbellEditScreen> createState() => _DoorbellEditScreenState();
}

class _DoorbellEditScreenState extends State<DoorbellEditScreen> {
  late Doorbell doorbell;

  @override
  Widget build(BuildContext context) {
    doorbell = DataStore.of(context).getDoorbellById(widget.doorbellId)!;
    var doorbellNameController = TextEditingController(text: doorbell.name);
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => RouteStateScope.of(context).go('/doorbells/${widget.doorbellId}'),
            color: CupertinoColors.activeBlue,
          ),
          middle: const Text('Edit Doorbell'),
        ),
        child: Container(
          color: CupertinoColors.systemGroupedBackground,
          child: ListView(scrollDirection: Axis.vertical, children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              // GENERAL
              CupertinoListSection.insetGrouped(
                additionalDividerMargin: 6,
                header: const Text(
                  'GENERAL',
                  style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
                ),
                children: <CupertinoListTile>[
                  CupertinoListTile(
                    title: CupertinoTextField(
                      controller: doorbellNameController,
                      onTapOutside: (event) async {
                        if (doorbell.name != doorbellNameController.text.trim() && doorbellNameController.text.isNotEmpty) {
                          doorbell.name = doorbellNameController.text;
                          await DataStore.of(context).updateDoorbellName(doorbell);
                        }
                      },
                      prefix: const Text('Name'),
                      decoration: const BoxDecoration(),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text('Silent mode time'),
                    additionalInfo: Text(doorbell.settings.automaticStateSettings != null
                        ? "${doorbell.settings.automaticStateSettings?.startTime} to ${doorbell.settings.automaticStateSettings?.endTime}"
                        : "Configure"),
                    trailing: const CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    title: const Text('Allow notifications'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool value) async {
                          doorbell.settings.enablePushNotifications = value;
                          await DataStore.of(context).updateDoorbellSettings(doorbell);
                          setState(() => doorbell);
                        },
                        value: doorbell.settings.enablePushNotifications),
                  ),
                ],
              ),

              // VOICE CALLS
              CupertinoListSection.insetGrouped(
                additionalDividerMargin: 6,
                header: const Text(
                  'VOICE CALLS',
                  style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
                ),
                children: <CupertinoListTile>[
                  CupertinoListTile(
                    title: const Text('Allow voice calls'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool value) async {
                          doorbell.settings.enableAudioCalls = value;
                          await DataStore.of(context).updateDoorbellSettings(doorbell);
                          setState(() => doorbell);
                        },
                        value: doorbell.settings.enableAudioCalls),
                  ),
                  const CupertinoListTile(
                    title: Text('Notification sound'),
                    additionalInfo: Text('Ding-dong'),
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),

              // VIDEO CALLS
              CupertinoListSection.insetGrouped(
                additionalDividerMargin: 6,
                header: const Text(
                  'VIDEO CALLS',
                  style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
                ),
                children: <CupertinoListTile>[
                  CupertinoListTile(
                    title: const Text('Allow video calls'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool value) async {
                          doorbell.settings.enableVideoCalls = value;
                          await DataStore.of(context).updateDoorbellSettings(doorbell);
                          setState(() => doorbell);
                        },
                        value: doorbell.settings.enableVideoCalls),
                  ),
                  CupertinoListTile(
                    title: const Text('Video preview'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool value) async {
                          doorbell.settings.enableVideoPreview = value;
                          await DataStore.of(context).updateDoorbellSettings(doorbell);
                          setState(() => doorbell);
                        },
                        value: doorbell.settings.enableVideoPreview),
                  ),
                  const CupertinoListTile(
                    title: Text('Notification sound'),
                    additionalInfo: Text('Ding-dong'),
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),

              // MESSAGES
              CupertinoListSection.insetGrouped(
                additionalDividerMargin: 6,
                header: const Text(
                  'MESSAGES',
                  style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
                ),
                children: <CupertinoListTile>[
                  CupertinoListTile(
                    title: const Text('Allow text messages'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool value) async {
                          doorbell.settings.enableTextMail = value;
                          await DataStore.of(context).updateDoorbellSettings(doorbell);
                          setState(() => doorbell);
                        },
                        value: doorbell.settings.enableTextMail),
                  ),
                  CupertinoListTile(
                    title: const Text('Allow voice messages'),
                    trailing: CupertinoSwitch(
                        onChanged: (bool value) async {
                          doorbell.settings.enableVoiceMail = value;
                          await DataStore.of(context).updateDoorbellSettings(doorbell);
                          setState(() => doorbell);
                        },
                        value: doorbell.settings.enableVoiceMail),
                  ),
                  const CupertinoListTile(
                    title: Text('Notification sound'),
                    additionalInfo: Text('Ding-dong'),
                    trailing: CupertinoListTileChevron(),
                  ),
                ],
              ),

              // DELETE DOORBELL
              CupertinoListSection.insetGrouped(
                children: <CupertinoListTile>[
                  CupertinoListTile(
                    title: Text(
                      "Delete '${doorbell.name}'",
                      style: const TextStyle(color: CupertinoColors.destructiveRed),
                    ),
                    onTap: () => _showDeleteConfirmationDialog(),
                  ),
                ],
              ),
            ]),
          ]),
        ));
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Delete '${doorbell.name}'"),
          content: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                  "Are you sure you want to delete\n'${doorbell.name}'?\n\nThis cannot be undone and all associated data will be lost.")),
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
                final route = RouteStateScope.of(context);
                await DataStore.of(context).removeDoorbell(widget.doorbellId);
                route.go('/doorbells');
              },
            ),
          ],
        );
      },
    );
  }
}
