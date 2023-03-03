// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/presentation/screens/login_screen.dart';
import 'package:qrdoorbell_mobile/presentation/screens/main_screen.dart';

import '../auth.dart';
import '../data.dart';
import '../routing.dart';
import '../widgets/fade_transition_page.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class AppNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AppNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final _signInKey = const ValueKey('Sign in');
  final _scaffoldKey = const ValueKey('App scaffold');
  final _doorbellDetailsKey = const ValueKey('Doorbell details screen');
  final _stickerTemplateDetailsKey = const ValueKey('Sticker details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = AppAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    Doorbell? selectedDoorbell;
    if (pathTemplate == '/doorbells/:doorbellId') {
      selectedDoorbell = storeInstance.allDoorbells.where((b) => b.id.toString() == routeState.route.parameters['doorbellId']).first;
    }

    // Author? selectedAuthor;
    // if (pathTemplate == '/author/:authorId') {
    //   selectedAuthor = libraryInstance.allAuthors.firstWhereOrNull((b) => b.id.toString() == routeState.route.parameters['authorId']);
    // }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // the /books or /authors tab in BookstoreScaffold.
        if (route.settings is Page && (route.settings as Page).key == _doorbellDetailsKey) {
          routeState.go('/doorbells');
        }

        // if (route.settings is Page && (route.settings as Page).key == _stickerDetailsKey) {
        //   routeState.go('/authors');
        // }

        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/login')
          // Display the sign in screen.
          FadeTransitionPage<void>(key: _signInKey, child: LoginScreen())
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: MainScreen(),
          ),
          // Add an additional page to the stack if the user is viewing a book
          // or an author
          // if (selectedDoorbell != null)
          //   MaterialPage<void>(
          //     key: _doorbellDetailsKey,
          //     child: MainScreen(
          //       book: selectedBook,
          //     ),
          //   )
          // else if (selectedAuthor != null)
          //   MaterialPage<void>(
          //     key: _stickerDetailsKey,
          //     child: AuthorDetailsScreen(
          //       author: selectedAuthor,
          //     ),
          //   ),
        ],
      ],
    );
  }
}
