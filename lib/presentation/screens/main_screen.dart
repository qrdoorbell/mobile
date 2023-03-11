import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:qrdoorbell_mobile/presentation/controls/event_list.dart';

import '../../data.dart';
import '../../routing/route_state.dart';
import '../controls/doorbell_list.dart';
import '../controls/profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final CupertinoTabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: 0)..addListener(_handleTabIndexChanged);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      backgroundColor: Colors.white,
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
        late final Widget tabWidget;
        late final String title;

        if (index == 0) {
          tabWidget = DoorbellList(
            onTapHandler: (Doorbell doorbell) async => await RouteStateScope.of(context).go('/doorbells/${doorbell.doorbellId}'),
          );
          title = 'Doorbells';
        } else if (index == 1) {
          tabWidget = const EventList();
          title = 'Events';
        } else if (index == 2) {
          tabWidget = Profile();
          title = 'Profile';
        } else {
          throw UnexpectedStateException('Invalid tab index');
        }

        return CupertinoTabView(
            builder: (context) => Container(
                color: Colors.white,
                width: double.maxFinite,
                height: double.maxFinite,
                child: CustomScrollView(
                  slivers: <Widget>[
                    CupertinoSliverNavigationBar(
                      transitionBetweenRoutes: true,
                      backgroundColor: Colors.white,
                      largeTitle: Text(title),
                      border: Border.all(width: 0, color: Colors.white),
                    ),
                    tabWidget,
                  ],
                )));
      },
    );
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 1:
        RouteStateScope.of(context).go('/events');
        break;
      case 2:
        RouteStateScope.of(context).go('/profile');
        break;
      case 0:
      default:
        RouteStateScope.of(context).go('/doorbells');
        break;
    }
  }
}
