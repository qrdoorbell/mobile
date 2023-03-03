// // Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// // for details. All rights reserved. Use of this source code is governed by a
// // BSD-style license that can be found in the LICENSE file.

// import 'package:adaptive_navigation/adaptive_navigation.dart';
// import 'package:flutter/material.dart';

// import '../routing.dart';
// import 'scaffold_body.dart';

// class AppScaffold extends StatelessWidget {
//   const AppScaffold({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final routeState = RouteStateScope.of(context);
//     final selectedIndex = _getSelectedIndex(routeState.route.pathTemplate);

//     return Scaffold(
//       body: AdaptiveNavigationScaffold(
//         selectedIndex: selectedIndex,
//         body: const BookstoreScaffoldBody(),
//         onDestinationSelected: (idx) {
//           if (idx == 0) routeState.go('/doorbells');
//           if (idx == 1) routeState.go('/events');
//           if (idx == 2) routeState.go('/profile');
//         },
//         destinations: const [
//           AdaptiveScaffoldDestination(
//             title: 'Doorbells',
//             icon: Icons.book,
//           ),
//           AdaptiveScaffoldDestination(
//             title: 'Events',
//             icon: Icons.person,
//           ),
//           AdaptiveScaffoldDestination(
//             title: 'Profile',
//             icon: Icons.settings,
//           ),
//         ],
//       ),
//     );
//   }

//   int _getSelectedIndex(String pathTemplate) {
//     if (pathTemplate.startsWith('/books')) return 0;
//     if (pathTemplate == '/authors') return 1;
//     if (pathTemplate == '/settings') return 2;
//     return 0;
//   }
// }
