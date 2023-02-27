import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:qrdoorbell_mobile/presentation/controls/event_list.dart';

import '../controls/doorbell_list.dart';
import '../../model/doorbell.dart';
import '../controls/profile.dart';

class TabPages {
  static const int doorbells = 0;
  static const int events = 1;
  static const int profile = 2;
}

class MainScreen extends StatefulWidget {
  MainScreen({
    super.key,
  });

  final String title = 'QR Doorbell / Home';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int page = TabPages.doorbells;
  final User user = FirebaseAuth.instance.currentUser!;

  final List<DoorbellCardViewModel> doorbells = [
    DoorbellCardViewModel(doorbell: Doorbell(id: '1', name: 'Doorbell 1'), announce: '2 missed calls'),
    DoorbellCardViewModel(doorbell: Doorbell(id: '2', name: 'Doorbell 2')),
    DoorbellCardViewModel(doorbell: Doorbell(id: '3', name: 'Doorbell My'), announce: 'Just created'),
    DoorbellCardViewModel(doorbell: Doorbell(id: '4', name: 'Doorbell Yours')),
    DoorbellCardViewModel(doorbell: Doorbell(id: '5', name: 'Doorbell Shared')),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Text("Doorbells", style: TextStyle(fontSize: 32)),
          padding: EdgeInsetsDirectional.only(start: 20),
          backgroundColor: Colors.white,
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
              items: const [
                BottomNavigationBarItem(
                  label: 'Doorbells',
                  icon: Icon(CupertinoIcons.qrcode),
                ),
                BottomNavigationBarItem(
                  label: 'Events',
                  icon: Icon(CupertinoIcons.bell),
                ),
                BottomNavigationBarItem(
                  label: 'Profile',
                  icon: Icon(CupertinoIcons.person),
                ),
              ],
              onTap: (value) {
                setState(() {
                  page = value;
                });
              }),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (context) {
                if (index == TabPages.doorbells) {
                  return DoorbellList(doorbells: doorbells);
                } else if (index == TabPages.events) {
                  return EventList();
                } else if (index == TabPages.profile) {
                  return Profile();
                } else {
                  throw UnexpectedStateException('Invalid tab index');
                }
              },
            );
          },
        ));
  }
}
