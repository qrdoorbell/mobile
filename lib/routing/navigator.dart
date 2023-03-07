import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/presentation/screens/doorbell_screen.dart';
import 'package:qrdoorbell_mobile/presentation/screens/login_screen.dart';
import 'package:qrdoorbell_mobile/presentation/screens/main_screen.dart';

import '../routing.dart';
import '../widgets/fade_transition_page.dart';

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
    final pathTemplate = routeState.route.pathTemplate;

    var doorbellId = routeState.route.parameters['doorbellId'];
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
          FadeTransitionPage<void>(key: _signInKey, child: LoginScreen())
        else ...[
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: MainScreen(),
          ),
          if (pathTemplate == '/doorbells/:doorbellId' && doorbellId != null)
            MaterialPage(
              key: _doorbellDetailsKey,
              child: DoorbellScreen(doorbellId: doorbellId),
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
