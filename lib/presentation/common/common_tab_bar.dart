import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class _CommonTabBarState extends State<CommonTabBar> {
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
            Navigator.pushNamed(context, "/doorbell");
          }),
      tabBuilder: (context, index) {
        return Text(currentSection.toString());
      },
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

class CommonTabBar extends StatefulWidget {
  const CommonTabBar({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _CommonTabBarState();
}
