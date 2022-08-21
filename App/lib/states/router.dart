import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/routes/child/camera.dart';
import 'package:solimage/routes/child/favorite.dart';
import 'package:solimage/routes/child/result.dart';
import 'package:solimage/routes/child/standby.dart';
import 'package:solimage/routes/parent/parent.dart';
import 'package:solimage/routes/parent/post.dart';
import 'package:solimage/routes/welcome.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/preferences.dart';

final List<Map<String, dynamic>> routes = [
  {'path': '/', 'name': 'welcome', 'child': const WelcomeScreen()},
  {'path': '/child/camera', 'name': 'camera', 'child': const CameraScreen()},
  {
    'path': '/child/favorite',
    'name': 'favorite',
    'child': const FavoriteScreen()
  },
  {'path': '/child/standby', 'name': 'standby', 'child': const StandbyScreen()},
  {'path': '/child/result', 'name': 'result', 'child': const ResultScreen()},
  {'path': '/parent', 'name': 'parent', 'child': const ParentScreen()},
  {'path': '/parent/post', 'name': 'post', 'child': const PostScreen()}
];

final routerProvider = Provider((ref) {
  return GoRouter(
      initialLocation: '/',
      routes: routes
          .map((route) => GoRoute(
                path: route['path'],
                name: route['name'],
                builder: (context, state) => SafeArea(child: route['child']),
              ))
          .toList(),
      redirect: (state) {
        final user = ref.read(userProvider);
        final prefs = ref.read(prefsProvider);

        if (user == null && state.subloc != '/') {
          return '/';
        } else if (user != null && state.subloc == '/') {
          return prefs.maybeWhen(data: (data) {
            final mode = data.getInt('mode');
            if (mode == 0) {
              return '/parent';
            } else if (mode == 1) {
              return '/child/camera';
            }
            return null;
          }, orElse: () {
            ref.refresh(prefsProvider);
            return null;
          });
        }

        return null;
      },
      refreshListenable: Listenable.merge([
        ValueNotifier(ref.watch(userProvider) != null),
        ValueNotifier(ref.watch(prefsProvider).asData != null)
      ]));
});
