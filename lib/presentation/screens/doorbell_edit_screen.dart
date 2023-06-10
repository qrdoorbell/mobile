import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../routing.dart';
import '../../data.dart';

var languages = Map<String, String>.from({
  "en": "English",
  "uk": "Ukrainian",
});

class DoorbellEditScreen extends StatefulWidget {
  final String doorbellId;

  const DoorbellEditScreen({super.key, required this.doorbellId});

  @override
  State<DoorbellEditScreen> createState() => _DoorbellEditScreenState();
}

class _DoorbellEditScreenState extends State<DoorbellEditScreen> {
  late Doorbell doorbell;

  bool silentModeControl = false;
  bool startTimeControl = false;
  bool endTimeControl = false;
  bool languageControl = false;

  @override
  Widget build(BuildContext context) {
    doorbell = DataStore.of(context).getDoorbellById(widget.doorbellId)!;
    var doorbellNameController = TextEditingController(text: doorbell.name);
    var pageTextController = TextEditingController(text: doorbell.settings.pageText);
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
                children: [
                  CupertinoListTile(
                    title: CupertinoTextField(
                      controller: doorbellNameController,
                      onTapOutside: (event) async {
                        if (doorbell.name != doorbellNameController.text.trim() && doorbellNameController.text.isNotEmpty) {
                          doorbell.name = doorbellNameController.text;
                          await DataStore.of(context).updateDoorbellName(doorbell);
                        }
                      },
                      onTap: () async => await _hideSilentModeControls(context),
                      prefix: const Text('Name'),
                      decoration: const BoxDecoration(),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text('Silent mode time'),
                    additionalInfo: Text(doorbell.settings.automaticStateSettings != null
                        ? "${DateFormat.Hm().format(doorbell.settings.automaticStateSettings!.startTime)} to ${DateFormat.Hm().format(doorbell.settings.automaticStateSettings!.endTime)}"
                        : "Configure"),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => setState(() => silentModeControl = !silentModeControl),
                  ),
                  if (silentModeControl)
                    CupertinoListTile(
                      title: const Padding(padding: EdgeInsets.only(left: 15), child: Text('Start time')),
                      additionalInfo: Text(doorbell.settings.automaticStateSettings != null
                          ? DateFormat.Hm().format(doorbell.settings.automaticStateSettings!.startTime)
                          : "Configure"),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => setState(() => startTimeControl = !startTimeControl),
                    ),
                  if (silentModeControl && startTimeControl)
                    SizedBox(
                      height: 200,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: doorbell.settings.automaticStateSettings?.startTime,
                        onDateTimeChanged: (newDateTime) {
                          setState(() {
                            (doorbell.settings.automaticStateSettings ??= TimeRangeForStateSettings.createDefault()).startTime =
                                newDateTime;
                          });
                        },
                      ),
                    ),
                  if (silentModeControl)
                    CupertinoListTile(
                      title: const Padding(padding: EdgeInsets.only(left: 15), child: Text('End time')),
                      additionalInfo: Text(doorbell.settings.automaticStateSettings != null
                          ? DateFormat.Hm().format(doorbell.settings.automaticStateSettings!.endTime)
                          : "Configure"),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => setState(() => endTimeControl = !endTimeControl),
                    ),
                  if (silentModeControl && endTimeControl)
                    SizedBox(
                      height: 200,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: true,
                        initialDateTime: doorbell.settings.automaticStateSettings?.startTime,
                        onDateTimeChanged: (newDateTime) {
                          setState(() {
                            (doorbell.settings.automaticStateSettings ??= TimeRangeForStateSettings.createDefault()).endTime = newDateTime;
                          });
                        },
                      ),
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

              // GUEST PAGE
              CupertinoListSection.insetGrouped(
                  additionalDividerMargin: 6,
                  header: const Text(
                    'GUEST PAGE',
                    style: TextStyle(fontSize: 13.0, color: CupertinoColors.inactiveGray, fontWeight: FontWeight.normal),
                  ),
                  children: [
                    CupertinoListTile(
                      title: CupertinoTextField(
                        controller: pageTextController,
                        onTapOutside: (event) async {
                          if (doorbell.settings.pageText != pageTextController.text.trim() && pageTextController.text.isNotEmpty) {
                            doorbell.settings.pageText = pageTextController.text;
                            await DataStore.of(context).updateDoorbellSettings(doorbell);
                          }
                        },
                        onTap: () async => await _hideSilentModeControls(context),
                        prefix: const Text('Page text'),
                        decoration: const BoxDecoration(),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('Language'),
                      additionalInfo: Text(languages[doorbell.settings.lang] ?? 'Default'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        setState(() => languageControl = !languageControl);
                      },
                    ),
                    if (languageControl)
                      for (var x in languages.entries)
                        CupertinoListTile(
                            title: Padding(padding: const EdgeInsets.only(left: 18), child: Text(x.value)),
                            trailing: doorbell.settings.lang == x.key
                                ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue)
                                : null,
                            onTap: () async {
                              setState(() {
                                doorbell.settings.lang = x.key;
                                languageControl = false;
                              });
                              await DataStore.of(context).updateDoorbellSettings(doorbell);
                            })
                  ]),

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
                final dataStore = DataStore.of(context);

                route.go('/doorbells', data: {"refresh": true});
                await dataStore.removeDoorbell(doorbell);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _hideSilentModeControls(BuildContext context) async {
    if (silentModeControl) {
      setState(() {
        silentModeControl = startTimeControl = endTimeControl = false;
      });
      await DataStore.of(context).updateDoorbellSettings(doorbell);
    }
  }
}
