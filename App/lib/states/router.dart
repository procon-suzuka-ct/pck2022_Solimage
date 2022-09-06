import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/observers/system_ui.dart';
import 'package:solimage/routes/child/camera.dart';
import 'package:solimage/routes/child/favorite.dart';
import 'package:solimage/routes/child/result.dart';
import 'package:solimage/routes/parent/parent.dart';
import 'package:solimage/routes/parent/post.dart';
import 'package:solimage/routes/welcome.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/preferences.dart';

final List<Map<String, dynamic>> routes = [
  {'path': '/', 'child': const WelcomeScreen()},
  {'path': '/child/camera', 'child': const CameraScreen()},
  {'path': '/child/result', 'child': const ResultScreen()},
  {'path': '/child/favorite', 'child': const FavoriteScreen()},
  {'path': '/parent', 'child': const ParentScreen()},
  {'path': '/parent/post', 'child': const PostScreen()}
];

final routerProvider = Provider((ref) => GoRouter(
    initialLocation: '/',
    routes: routes
        .map((route) => GoRoute(
              path: route['path'],
              name: route['path'],
              builder: (context, state) => SafeArea(child: route['child']),
            ))
        .toList(),
    observers: [SystemUiObserver()],
    redirect: (state) {
      final auth = ref.read(authProvider);
      final prefs = ref.read(prefsProvider);

      return auth.when(
          data: (data) {
            if (data == null && state.subloc != '/') {
              return '/';
            } else if (data != null && state.subloc == '/') {
              return prefs.maybeWhen(
                  data: (data) {
                    final mode = data.getInt('mode');
                    if (mode == 0) {
                      return '/parent';
                    } else if (mode == 1) {
                      return '/child/camera';
                    }
                    return null;
                  },
                  orElse: () => null);
            }
            return null;
          },
          loading: () => null,
          error: (error, stack) => null);
    },
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(ref.watch(authProvider.stream)),
      GoRouterRefreshStream(ref.watch(prefsProvider.stream))
    ]),
    debugLogDiagnostics: true));
