import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

final routerProvider = Provider((ref) {
  return GoRouter(
      initialLocation: '/parent/settings',
      routes: [
        GoRoute(
            path: '/',
            name: 'welcome',
            builder: (context, state) =>
                const SafeArea(child: WelcomeScreen())),
        GoRoute(
            path: '/child/camera',
            name: 'camera',
            builder: (context, state) => const SafeArea(child: CameraScreen())),
        GoRoute(
            path: '/child/favorite',
            name: 'favorite',
            builder: (context, state) =>
                const SafeArea(child: FavoriteScreen())),
        GoRoute(
            path: '/child/standby',
            name: 'standby',
            builder: (context, state) =>
                const SafeArea(child: StandbyScreen())),
        GoRoute(
            path: '/child/result',
            name: 'result',
            builder: (context, state) => const SafeArea(child: ResultScreen())),
        GoRoute(
            path: '/parent/history',
            name: 'history',
            builder: (context, state) =>
                const SafeArea(child: ParentScreen(tab: 'history'))),
        GoRoute(
            path: '/parent/settings',
            name: 'settings',
            builder: (context, state) =>
                const SafeArea(child: ParentScreen(tab: 'settings'))),
        GoRoute(
            path: '/parent/post',
            name: 'post',
            builder: (context, state) => const SafeArea(child: PostScreen())),
      ],
      redirect: (state) {
        final user = ref.read(userProvider);
        final prefs = ref.read(prefsProvider);

        if (user == null && state.subloc != '/') {
          return '/';
        } else if (user != null && state.subloc == '/') {
          return prefs.maybeWhen(data: (data) {
            final mode = data.getInt('mode');
            if (mode == 0) {
              return '/parent/history';
            } else if (mode == 1) {
              return '/child/camera';
            }
            return null;
          }, orElse: () {
            ref.refresh(prefsProvider);
            return null;
          });
        }

        if (state.subloc.contains('/child')) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }

        return null;
      },
      refreshListenable: Listenable.merge([
        ValueNotifier(ref.watch(userProvider) != null),
        ValueNotifier(ref.watch(prefsProvider).asData != null)
      ]));
});
