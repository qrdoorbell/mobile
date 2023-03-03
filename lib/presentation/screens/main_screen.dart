import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:qrdoorbell_mobile/presentation/controls/event_list.dart';

import '../../data.dart';
import '../../routing/route_state.dart';
import '../controls/doorbell_list.dart';
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
          tabWidget = DoorbellList(
            doorbells: DataStore()
                .allDoorbells
                .map((e) => DoorbellCardViewModel(doorbell: e, announce: e.id == '1' ? 'First one' : 'No new messages'))
                .toList(),
            onTapHandler: _onDoorbellSelected,
          );
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

  Future<void> _onDoorbellSelected(Doorbell doorbell) async {
    await _routeState.go('/doorbells/${doorbell.id}');
  }

  void _handleTabIndexChanged() {
    switch (_tabController.index) {
      case 1:
        _routeState.go('/events');
        break;
      case 2:
        _routeState.go('/profile');
        break;
      case 0:
      default:
        _routeState.go('/doorbells');
        break;
    }
  }
}
