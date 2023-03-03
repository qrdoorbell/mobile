import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:qrdoorbell_mobile/presentation/controls/event_list.dart';

import '../../routing/route_state.dart';
import '../controls/doorbell_list.dart';
import '../../model/doorbell.dart';
import '../controls/profile.dart';

class MainScreenTabPages {
  static const int doorbells = 0;
  static const int events = 1;
  static const int profile = 2;
}

class MainScreen extends StatelessWidget {
  MainScreen({
    super.key,
  }) {
    _tabController = CupertinoTabController(initialIndex: 0)..addListener(_handleTabIndexChanged);
  }

  final User user = FirebaseAuth.instance.currentUser!;
  late final CupertinoTabController _tabController;
  late final RouteState _routeState;

  final List<DoorbellCardViewModel> doorbells = [
    DoorbellCardViewModel(doorbell: Doorbell(id: '1', name: 'Doorbell 1'), announce: '2 missed calls'),
    DoorbellCardViewModel(doorbell: Doorbell(id: '2', name: 'Doorbell 2')),
    DoorbellCardViewModel(doorbell: Doorbell(id: '3', name: 'Doorbell My'), announce: 'Just created'),
    DoorbellCardViewModel(doorbell: Doorbell(id: '4', name: 'Doorbell Yours')),
    DoorbellCardViewModel(doorbell: Doorbell(id: '5', name: 'Doorbell Shared')),
  ];

  @override
  Widget build(BuildContext context) {
    _routeState = RouteStateScope.of(context);

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

        if (index == MainScreenTabPages.doorbells) {
          tabWidget = DoorbellList(doorbells: doorbells);
          title = 'Doorbells';
        } else if (index == MainScreenTabPages.events) {
          tabWidget = EventList();
          title = 'Events';
        } else if (index == MainScreenTabPages.profile) {
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
        _routeState.go('/books/new');
        break;
      case 2:
        _routeState.go('/books/all');
        break;
      case 0:
      default:
        _routeState.go('/books/popular');
        break;
    }
  }
}
