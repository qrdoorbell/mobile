import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../data.dart';
import '../../routing/route_state.dart';
import '../controls/event_list.dart';
import '../controls/doorbell_list.dart';
import 'profile_screen.dart';
import 'empty_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late final CupertinoTabController _tabController;

  @override
  void initState() {
    _tabController = CupertinoTabController(initialIndex: 0)..addListener(_handleTabIndexChanged);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndexChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dataStore = DataStore.of(context);
    if (!dataStore.isLoaded || dataStore.currentUser?.userId.isEmpty == true || FirebaseAuth.instance.currentUser == null) {
      return EmptyScreen.white().withWaitingIndicator();
    }

    return CupertinoTabScaffold(
      controller: _tabController,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return _getTabWidget(
                DoorbellList(), 'Doorbells', FloatingActionButton(onPressed: createDoorbell, child: const Icon(CupertinoIcons.add)));
          case 1:
            return _getTabWidget(const EventList(), 'Events', null);
          case 2:
            return const ProfileScreen();
          default:
            throw UnexpectedStateException('Invalid tab index');
        }
      },
    );
  }

  Future<void> _onRefreshNeeded() async {
    await DataStore.of(context).reloadData(true);
  }

  Future<void> createDoorbell() async {
    final dataStore = DataStore.of(context);
    if (dataStore.doorbells.items.length >= 5) {
      _showAlert(context);
      return;
    }

    final routeState = RouteStateScope.of(context);
    await routeState.wait((() async {
      var doorbell = await dataStore.createDoorbell();
      await dataStore.reloadData(true);

      return doorbell;
    })(), destinationRouteFunc: (newDoorbell) => '/doorbells/${newDoorbell.doorbellId}');
  }

  Widget _getTabWidget(Widget widget, String title, FloatingActionButton? floatButton) {
    return CupertinoTabView(
        builder: (context) => Container(
            color: Colors.white,
            width: double.maxFinite,
            height: double.maxFinite,
            child: Scaffold(
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                floatingActionButton: floatButton,
                backgroundColor: Colors.white,
                body: CustomScrollView(
                  slivers: <Widget>[
                    CupertinoSliverNavigationBar(
                      transitionBetweenRoutes: true,
                      backgroundColor: Colors.white,
                      padding: EdgeInsetsDirectional.zero,
                      largeTitle: Text(title),
                      border: Border.all(width: 0, color: Colors.white),
                    ),
                    CupertinoSliverRefreshControl(onRefresh: _onRefreshNeeded),
                    widget,
                    const SliverPadding(padding: EdgeInsets.only(top: 70)),
                  ],
                ))));
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 1:
        RouteStateScope.of(context).go('/events');
        break;
      case 2:
        RouteStateScope.of(context).go('/profile');
        break;
      default:
        RouteStateScope.of(context).go('/doorbells');
        break;
    }
  }

  void _showAlert(BuildContext context) {
    var alert = CupertinoAlertDialog(
        title: const Text("Maximum Doorbells limit"),
        content: const Text("\nUsers are allowed to have up to\n5 Doorbells today.\n\nPlease reach out support team for more details."),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ]);

    showDialog(
        useRootNavigator: true,
        routeSettings: const RouteSettings(name: '/doorbells'),
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
