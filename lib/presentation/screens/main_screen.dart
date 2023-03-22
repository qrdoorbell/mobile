import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../data.dart';
import '../../routing/route_state.dart';
import '../controls/doorbell_list.dart';
import '../controls/event_list.dart';
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
        FloatingActionButton? floatButton;

        if (index == 0) {
          tabWidget = DoorbellList(
            onTapHandler: (Doorbell doorbell) async => await RouteStateScope.of(context).go('/doorbells/${doorbell.doorbellId}'),
          );
          title = 'Doorbells';
          floatButton = FloatingActionButton(
              child: const Icon(CupertinoIcons.add),
              onPressed: () async {
                final dataStore = DataStore.of(context);
                if (dataStore.doorbells.length >= 5) {
                  _showAlert(context);
                  return;
                }

                final routeState = RouteStateScope.of(context);
                final newDoorbell = await dataStore.createDoorbell();
                await routeState.go('/doorbells/${newDoorbell.doorbellId}');
              });
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
                child: Scaffold(
                    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                    floatingActionButton: floatButton,
                    backgroundColor: Colors.white,
                    body: CustomScrollView(
                      slivers: <Widget>[
                        CupertinoSliverNavigationBar(
                          transitionBetweenRoutes: true,
                          backgroundColor: Colors.white,
                          largeTitle: Text(title),
                          border: Border.all(width: 0, color: Colors.white),
                        ),
                        tabWidget,
                      ],
                    ))));
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
