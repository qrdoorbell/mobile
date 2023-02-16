import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'doorbell_details_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    // this.analytics,
    // this.observer,
  });

  final String title = 'QR Doorbell / Home';
  // final FirebaseAnalytics analytics;
  // final FirebaseAnalyticsObserver observer;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userName = "-";
  var currentSection = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
              label: 'A',
              icon: Icon(Icons.abc_outlined),
            ),
            BottomNavigationBarItem(
              label: 'B',
              icon: Icon(Icons.ac_unit_outlined),
            ),
            BottomNavigationBarItem(
              label: 'C',
              icon: Icon(Icons.access_alarm_outlined),
            ),
          ],
          onTap: (value) {
            currentSection = value;
            Navigator.push(context, MaterialPageRoute(builder: (context) => DoorbellDetailsScreen()));
          }),
      tabBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Padding(padding: EdgeInsets.symmetric(vertical: 15), child: WordPairWidget(pair: pair)),
            Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text(userName)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ElevatedButton(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        child: Column(children: [
                          Row(children: [
                            Icon(Icons.doorbell_outlined),
                            Text('Next'),
                          ])
                        ])),
                    onPressed: () async {
                      var value = await FirebaseAuth.instance.signInWithEmailAndPassword(email: "a@qx.zone", password: "1234Qwer-");
                      setState(() {
                        userName = value.user?.displayName ?? "N/A";
                      });
                    }),
              ],
            ),
          ],
        );
      },
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
