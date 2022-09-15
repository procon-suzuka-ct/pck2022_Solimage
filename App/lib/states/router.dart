import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solimage/observers/system_ui.dart';
import 'package:solimage/routes/child/camera.dart';
import 'package:solimage/routes/child/history.dart';
import 'package:solimage/routes/child/result.dart';
import 'package:solimage/routes/parent/parent.dart';
import 'package:solimage/routes/parent/post.dart';
import 'package:solimage/routes/welcome.dart';
import 'package:solimage/states/auth.dart';
import 'package:solimage/states/preferences.dart';

final List<Map<String, dynamic>> routes = [
  {'path': '/child/camera', 'child': const CameraScreen()},
  {'path': '/child/history', 'child': const HistoryScreen()},
  {'path': '/child/result', 'child': const ResultScreen()},
  {'path': '/parent', 'child': const ParentScreen()},
  {'path': '/parent/post', 'child': const PostScreen()},
  {'path': '/', 'child': const WelcomeScreen()}
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

      return auth.maybeWhen(data: (data) {
        if (data == null) {
          if (state.subloc != '/') {
            return '/';
          } else {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => FlutterNativeSplash.remove());
          }
        } else if (state.subloc == '/') {
          return prefs.maybeWhen(data: (data) {
            final mode = data.getInt('mode');
            if (mode != null) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => FlutterNativeSplash.remove());
              if (mode == 0) {
                return '/parent';
              } else if (mode == 1) {
                return '/child/camera';
              }
            }
            FlutterNativeSplash.remove();
            return null;
          }, orElse: () {
            return null;
          });
        }
        return null;
      }, orElse: () {
        return null;
      });
    },
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(ref.watch(authProvider.stream)),
      GoRouterRefreshStream(ref.watch(prefsProvider.stream))
    ]),
    debugLogDiagnostics: true));
